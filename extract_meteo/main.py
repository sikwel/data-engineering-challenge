import requests
import pandas as pd
import logging 

def get_meteo_data(lat, long, start_date, end_date, tz='GMT+1'):

    # TODO assure proper inputs
    # TODO docstring        

    # see doc to select fields: https://open-meteo.com/en/docs
    requested_fields_hourly = [
        "temperature_2m",
        "relative_humidity_2m",
        "rain",
        "weather_code",
        "surface_pressure",
        "wind_speed_10m"
    ]

    test_url = r"https://api.open-meteo.com/v1/forecast"
    query_params = {
        "latitude": lat,
        "longitude": long,
        "hourly": ",".join(requested_fields_hourly),
        "start_date": start_date,
        "end_date": end_date,
        "timezone": tz
    }

    # TODO try except 
    response = requests.get(test_url, query_params)
    data = pd.json_normalize(response.json())
    
    # we need to unpack the columns
    explode_list = ["hourly." + s for s in requested_fields_hourly]
    explode_list.append("hourly.time")
    df_out = data.explode(explode_list) 

    return df_out


df = get_meteo_data(
    regions["Latitude"],
    regions["Longitude"],
    '2025-01-01',
    '2025-02-03',
    'GMT+1'
)


###### SANDBOX

# Read mapping
path = r"M:\Code\sikwel_codingchallenge\data-engineering-challenge\data\aux_data\mapping_region_coords.csv"
regions = pd.read_csv(path, sep=" ")

## Connect to Duck DB
import duckdb
con = duckdb.connect('../duckdb/dev_db.duckdb')
con.close()