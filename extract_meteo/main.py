import requests
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry
import pandas as pd
import logging 
import duckdb
import argparse
import geohash2 as gh

# Loggin config
logging.basicConfig(
    level=logging.INFO, 
    format='%(asctime)s - %(levelname)s - %(message)s',
    force = True
)

# Get input args
parser = argparse.ArgumentParser()
parser.add_argument('--env', type=str, default='dev', help='Environment to work with')
parser.add_argument('--load_type', type=str, default='incremental', help='Loading type of data')
parser.add_argument('--lat', type=float, default=34.31295, help='Latitude of weather data')
parser.add_argument('--long', type=float, default=-78.16111, help='Longitude of weather data')
parser.add_argument('--start_date', type=str, default='2025-01-01', help='Start date of selected data')
parser.add_argument('--end_date', type=str, default='2025-01-03', help='End date of selected data')
parser.add_argument('--tz', type=str, default='UTC', help='Timezone of selected data')
args = parser.parse_args()

logging.info(f"Started data pipeline 'METEO_DATA'. Environment: {args.env}, Load Type: {args.load_type}")

# SQL statements
sql_create_table = f"""CREATE TABLE weather_data_hourly (
    geohash TEXT,
    latitude DOUBLE,
    longitude DOUBLE,
    timezone TEXT,
    time TIMESTAMP,
    temperature DOUBLE,
    relative_humidity INTEGER,
    rain DOUBLE,
    weather_code INTEGER,
    wind_speed DOUBLE,
    surface_pressure DOUBLE,
    data_time_stamp TIMESTAMP,
    UNIQUE(geohash, timezone, time)
)"""

sql_drop_table = f"""DROP TABLE IF EXISTS weather_data_hourly;"""

sql_insert_values = f"""INSERT OR REPLACE INTO weather_data_hourly SELECT * FROM extracted_data"""

# Extraction function
def get_meteo_data(lat: float, long: float, start_date: str, end_date: str, tz: str = 'GMT+1'):
    """
    Fetches meteorological data from the Open-Meteo API.

    Parameters:
    lat (float): Latitude of the location.
    long (float): Longitude of the location.
    start_date (str): Start date for the data in YYYY-MM-DD format.
    end_date (str): End date for the data in YYYY-MM-DD format.
    tz (str): Timezone of the data. Default is 'GMT+1'.

    Returns:
    pd.DataFrame: DataFrame containing the meteorological data.
    """
    # see doc to select fields: https://open-meteo.com/en/docs
    requested_fields_hourly = [
        "temperature_2m",
        "relative_humidity_2m",
        "rain",
        "weather_code",
        "wind_speed_10m",
        "surface_pressure"
    ]

    endpoint = r"https://historical-forecast-api.open-meteo.com/v1/forecast"
    
    query_params = {
        "latitude": lat,
        "longitude": long,
        "hourly": ",".join(requested_fields_hourly),
        "start_date": start_date,
        "end_date": end_date,
        "timezone": tz
    }
    logging.info(f"Requesting data from {endpoint} with the following query params: {query_params}")

    # i ran into problems, when extracting huge chunks of data, so we have to connect with the API a bit more sophisticated
    session = requests.Session()
    retry = Retry(
        total=5,
        backoff_factor=1,
        status_forcelist=[429, 500, 502, 503, 504],
        allowed_methods=["GET"]
    )
    adapter = HTTPAdapter(max_retries=retry)
    session.mount("https://", adapter)
    session.mount("http://", adapter)

    response = session.get(endpoint, params=query_params)

    if response.status_code != 200:
        logging.error(f"Request failed with status code {response.status_code}")
        raise ValueError("Request failed")
    else:
        logging.info("Request successful")
        data = pd.json_normalize(response.json())
        if not isinstance(data, pd.DataFrame):
            logging.error("Data is not a DataFrame")
            raise ValueError("Data is not a DataFrame")

    # Minor transformations

    ## Unpack columns
    explode_list = ["hourly." + s for s in requested_fields_hourly]
    explode_list.append("hourly.time")
    df_out = data.explode(explode_list) 

    ## Clean index
    df_out.reset_index(drop=True, inplace=True)

    # Adding geohash
    df_out["geohash"] = df_out.apply(lambda row: gh.encode(row['latitude'], row['longitude'], precision=3), axis=1)

    # Slice the wanted columns
    cols_of_interest = ['geohash', 'latitude', 'longitude', 'timezone_abbreviation', "hourly.time"] + ['hourly.' + s for s in requested_fields_hourly]
    df_out = df_out[cols_of_interest]

    # Adding data timestamp for transparency
    df_out["data_time_stamp"] = pd.Timestamp.utcnow()

    return df_out



def main(env=args.env, load_type=args.load_type, lat=args.lat, long=args.long, start_date=args.start_date, end_date=args.end_date, tz=args.tz):
    """
    Main function to extract meteorological data and load it into a DuckDB database.
    Parameters:
    env (str): The environment in which the script is running. Default is 'dev'.
    load_type (str): The type of load operation to perform. Must be 'full' or 'incremental'.
    lat (float): Latitude for the data extraction.
    long (float): Longitude for the data extraction.
    start_date (str): Start date for the data extraction in 'YYYY-MM-DD' format.
    end_date (str): End date for the data extraction in 'YYYY-MM-DD' format.
    tz (str): Timezone for the data extraction.
    Raises:
    NotImplementedError: If the environment is not 'dev' or if the load type is invalid.
    Logs:
    - Number of rows extracted.
    - Number of rows with null values.
    - Connection establishment to DuckDB.
    - Table drop, creation, and data insertion operations.
    - Connection closure to DuckDB.
    """
    if env == 'dev':
        db_conn_str = 'duckdb/dev_db.duckdb'
    else:
        raise NotImplementedError("Only dev environment is supported")

    # extract
    extracted_data = get_meteo_data(
        lat,
        long,
        start_date,
        end_date,
        tz
    )
    logging.info(f"Extracted {len(extracted_data)} rows of data")

    num_rows_with_nulls = extracted_data.isnull().any(axis=1).sum()
    if num_rows_with_nulls > 0:    
        logging.warning(f"There are {num_rows_with_nulls} rows with at least one null value in the extracted data")
    
    con = duckdb.connect(db_conn_str)
    logging.info("Established conn to DuckDB")

    if load_type == 'full':
        con.execute(sql_drop_table)
        logging.info("Dropped table")
        con.execute(sql_create_table)
        logging.info("Created table")
        
        con.execute(sql_insert_values)
        logging.info("Inserted values")

    elif load_type == 'incremental':
        con.execute(sql_insert_values)
        logging.info("Inserted values")

    else:
        logging.error("Invalid load type")
        raise NotImplementedError("Load type must be 'full' or 'incremental'")

    con.close()
    logging.info("Closed conn to DuckDB")


if __name__ == '__main__':
    main() 