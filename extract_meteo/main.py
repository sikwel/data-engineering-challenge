import requests
import pandas as pd

test_url = r"https://api.open-meteo.com/v1/forecast?latitude=52.52&longitude=13.41&hourly=temperature_2m"



# see doc to select fields: https://open-meteo.com/en/docs
requested_fields_hourly = [
    "temperature_2m",
    "relative_humidity_2m",
    "rain",
    "weather_code",
    "surface_pressure",
    "wind_speed_10m"
]

lat = 52.52
long = 13.41

all_feats_url = rf"https://api.open-meteo.com/v1/forecast?latitude={lat}&longitude={long}&hourly="+",".join(requested_fields_hourly)


response = requests.get(all_feats_url)

df = pd.json_normalize(response.json())