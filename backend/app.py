from flask import Flask, request, jsonify
import requests
import numpy as np
import pickle

app = Flask(__name__)

# 🔹 Get weather data from Open-Meteo
def get_weather(lat, lon):
    url = f"https://api.open-meteo.com/v1/forecast?latitude={lat}&longitude={lon}&current_weather=true&hourly=precipitation,pressure_msl"
    
    response = requests.get(url)
    data = response.json()

    temp = data['current_weather']['temperature']
    wind = data['current_weather']['windspeed']

    # Rain & pressure (hourly data)
    rainfall = data.get('hourly', {}).get('precipitation', [0])[0]
    pressure = data.get('hourly', {}).get('pressure_msl', [1013])[0]

    return temp, wind, rainfall, pressure


# 🔹 Get earthquake data from USGS
def get_earthquakes(lat, lon):
    url = "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson"
    try:
        response = requests.get(url)
        data = response.json()
        
        for feature in data['features']:
            coords = feature['geometry']['coordinates']
            mag = feature['properties']['mag']
            # Coordinates are [lon, lat, depth]
            e_lon, e_lat = coords[0], coords[1]
            
            # Simple distance check (approx 2 degree radius ~ 220km)
            if abs(e_lat - lat) < 2 and abs(e_lon - lon) < 2:
                if mag >= 4.0:
                    return f"Nearby Earthquake: M{mag} at {feature['properties']['place']}"
    except Exception as e:
        print(f"USGS Error: {e}")
    return None


# 🔹 Load Models
try:
    rf_model = pickle.load(open('rf_model.pkl', 'rb'))
except Exception as e:
    print(f"RF Model Load Error: {e}")
    rf_model = None

try:
    from tensorflow.keras.models import load_model
    lstm_model = load_model("lstm_model.h5")
except:
    lstm_model = None

# LSTM Prediction Logic (Window: 3 days, 3 features)
def predict_lstm(input_data):
    if not lstm_model:
        return None
    try:
        input_data = np.array(input_data)
        input_data = input_data.reshape((1, 3, 3))  # 3 days, 3 features
        prediction = lstm_model.predict(input_data)
        return float(prediction[0][0])
    except Exception as e:
        print(f"LSTM Prediction Error: {e}")
        return None


# 🔹 Hybrid Prediction Logic
def hybrid_prediction(rainfall, temp, humidity, wind, pressure):
    # Step 1: Quick rule filter
    if rainfall < 20 and wind < 50:
        return "No Immediate Risk"

    # Step 2: ML model
    if not rf_model:
        return "Model Unavailable"
        
    features = [[rainfall, temp, humidity, wind, pressure]]
    pred = rf_model.predict(features)[0]

    # Step 3: Final prediction
    if pred == 1:
        return "Disaster Risk: High"
    else:
        return "Moderate Risk"


@app.route('/')
def home():
    return "Multi-Disaster Prediction API Running"


@app.route('/predict', methods=['POST'])
def predict():
    data = request.json

    lat = data['lat']
    lon = data['lon']

    # Magnitude for simulation
    magnitude = data.get('magnitude', 0)

    # 1. Get real-time data
    temp, wind, rainfall, pressure = get_weather(lat, lon)
    humidity = 80 # Placeholder or fetch if available

    # 2. Hybrid Prediction
    main_result = hybrid_prediction(rainfall, temp, humidity, wind, pressure)
    
    predictions = [main_result]

    # 3. Future Insight (LSTM)
    last_3_days = [
        [10, 30, 60],
        [20, 31, 65],
        [50, 29, 70]
    ]
    future_rain = predict_lstm(last_3_days)

    if future_rain and future_rain > 100:
        predictions.append("Future Flood Risk")

    # 4. Supplemental Checks
    usgs_alert = get_earthquakes(lat, lon)
    if usgs_alert:
        predictions.append(usgs_alert)

    if magnitude >= 6:
        predictions.append("Simulation: Major Earthquake Alert")

    return jsonify({
        "temperature": temp,
        "wind_speed": wind,
        "rainfall": rainfall,
        "pressure": pressure,
        "prediction": predictions,
        "forecast": future_rain
    })


if __name__ == '__main__':
    app.run(debug=True)
