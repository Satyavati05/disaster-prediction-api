import pandas as pd
from sklearn.linear_model import LogisticRegression
import pickle

# Load dataset
try:
    data = pd.read_csv("data.csv")

    X = data[['rainfall', 'temperature', 'humidity', 'wind_speed', 'pressure']]
    y = data['disaster']

    # Train model
    model = LogisticRegression(max_iter=1000)
    model.fit(X, y)

    # Save model
    pickle.dump(model, open('logistic_model.pkl', 'wb'))

    print("Logistic Model Ready")
except Exception as e:
    print(f"Error training model: {e}")
