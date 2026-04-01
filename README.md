#  AI-Based Climate Change & Disaster Prediction System

## Overview

This project is an AI-powered disaster management system that predicts natural disasters such as floods, cyclones, and cloudbursts using real-time weather data and machine learning models.

It also integrates real-time earthquake monitoring using USGS data.


## Features

* Flood Prediction using weather data
* Cyclone Risk Detection
* Cloudburst Detection
* Real-time Earthquake Monitoring
* Alert Notification System
* Real-time Weather API integration
* Machine Learning Model (Random Forest)


## Tech Stack

* Backend: Python, Flask
* Frontend: Flutter
* Machine Learning: Scikit-learn
* APIs: Open-Meteo, USGS
* Database: Firebase


## System Architecture

Weather API → Flask Backend → ML Model → Prediction → Flutter App → Alerts


## Project Structure for backend

* app.py
* data.csv
* logistic_model.pkl
* logistic_model.py
* lstm_model.py
* procfile
* requirements.txt
* rf_model.pkl
* rf_model.py
* time_series.csv


## How to Run

1. Install dependencies:
   pip install -r requirements.txt

2. Run backend:
   python app.py


## Deployment

Backend is deployed using Render and connected via GitHub.


## Future Scope

* Integration with satellite data
* LSTM-based time series prediction
* Advanced disaster mapping



## References

* Open-Meteo API
* USGS Earthquake API

