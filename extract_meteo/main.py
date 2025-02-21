import requests
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry
import pandas as pd
import logging 
import duckdb
import argparse
import geohash2 as gh

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

# Accessing the arguments
config = {
    "Environment": args.env,
    "Load Type": args.load_type,
    "Latitude": args.lat,
    "Longitude": args.long,
    "Start Date": args.start_date,
    "End Date": args.end_date,
    "Timezone": args.tz
}

logging.info(f"Started data pipeline 'METEO_DATA'. Environment: {args.env}, Load Type: {args.load_type}")


# DISCUSSION
# We should make sure the tuple (latitude, longitude, timezone, time) is unique
# Of course we can test and clean this up later in dbt or so too, but I believe the cleaner the DB, the better
# So I will do this using UNIQUE constraint and therefore I prescribe an explicit data schema here. 
# This also allows us to INSERT OR REPLACE when using incremental loading.

# Alternatively, we could also use a data-time-stamp and only take the latest / earliest entries, in case there are doubletes of (latitude, longitude, timezone, time)
# lets stick with the schema approach now ....  "Explicit is better than implicit" (zen of py)


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


def get_meteo_data(lat, long, start_date, end_date, tz='GMT+1'):

    # TODO assure proper inputs
    # TODO docstring        

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
  

    # DISCUSSION ... 
    # I was considering to enforce some of the data types here in the py-workspace. 
    # Why? For example, when throwing the data into DuckDB, some of the Dtypes already will get casted.
    # So I cannot compare input and output df1.equals(df2)
    # Also: In earlier work I had some trouble with timestamps as well ...
    # In the end i decided to not enforce dtypes here, since we have an explicit schema in the CREATE TABLE statement already
    

    ## Clean index
    df_out.reset_index(drop=True, inplace=True)

    # Adding geohash
    df_out["geohash"] = df_out.apply(lambda row: gh.encode(row['latitude'], row['longitude'], precision=4), axis=1)

    # Slice the wanted columns
    cols_of_interest = ['geohash', 'latitude', 'longitude', 'timezone_abbreviation', "hourly.time"]+['hourly.' + s for s in requested_fields_hourly]
    df_out = df_out[cols_of_interest]

    # Adding data timestamp for transparency
    df_out["data_time_stamp"] = pd.Timestamp.utcnow()

    # TODO check if there is a json
    # TODO check if all columns are there
    # TODO check if data is meaningfull - warn
    
    return df_out



# TODO: it depends where we run this, if it works or not!
def main(db_conn_str = '../duckdb/dev_db.duckdb', load_type=args.load_type, lat = args.lat, long = args.long, start_date = args.start_date, end_date = args.end_date, tz=args.tz):

    # extract
    extracted_data = get_meteo_data(
        lat,
        long,
        start_date,
        end_date,
        tz
    )
    logging.info(f"Extraced {len(extracted_data)} rows of data")

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


# TESTING
# con = duckdb.connect('../duckdb/dev_db.duckdb')
# df = con.execute(f"SELECT * FROM weather_data_hourly").fetchdf()
# con.close()


# df = get_meteo_data(
#     test_region["Latitude"],
#     test_region["Longitude"],
#     '2025-01-01',
#     '2025-02-03',
#     'GMT+1'
# )

# lookup regions
# regions = pd.read_csv(r"M:\Code\sikwel_codingchallenge\data-engineering-challenge\data\aux_data\mapping_region_coords.csv", sep=" ")
