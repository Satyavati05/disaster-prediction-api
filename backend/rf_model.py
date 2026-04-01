import pandas as pd
from sklearn.ensemble import RandomForestClassifier
import pickle

# Load dataset
try:
    data = pd.read_csv("data.csv")

    X = data[['rainfall', 'temperature', 'humidity', 'wind_speed', 'pressure']]
    y = data['disaster']

    # Train model
    model = RandomForestClassifier(n_estimators=100)
    model.fit(X, y)

    # Save model
    pickle.dump(model, open('rf_model.pkl', 'wb'))

    print("Random Forest Model Ready")
except Exception as e:
    print(f"Error training model: {e}")
