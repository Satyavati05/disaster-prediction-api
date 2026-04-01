import numpy as np
import pandas as pd
try:
    from tensorflow.keras.models import Sequential
    from tensorflow.keras.layers import LSTM, Dense
    from sklearn.preprocessing import MinMaxScaler

    # Load data
    data = pd.read_csv("time_series.csv")

    values = data[['rainfall', 'temp', 'humidity']].values

    # Scale data
    scaler = MinMaxScaler()
    values = scaler.fit_transform(values)

    # Create sequences
    X = []
    y = []

    for i in range(3, len(values)):
        X.append(values[i-3:i])  # last 3 days
        y.append(values[i][0])   # predict rainfall

    X, y = np.array(X), np.array(y)

    # Build model
    model = Sequential()
    model.add(LSTM(50, return_sequences=False, input_shape=(X.shape[1], X.shape[2])))
    model.add(Dense(1))

    model.compile(optimizer='adam', loss='mean_squared_error')

    # Train
    print("Training LSTM Model...")
    model.fit(X, y, epochs=10, batch_size=1)

    # Save model
    model.save("lstm_model.h5")

    print("LSTM Model Ready")

except ImportError as e:
    print(f"Error: Missing library - {e}")
    print("Please install TensorFlow via: pip install tensorflow")
except Exception as e:
    print(f"An unexpected error occurred: {e}")
