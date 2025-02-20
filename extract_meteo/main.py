import requests
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
parser.add_argument('--lat', type=float, default = 34.31295, help='Latitude of weather data')
parser.add_argument('--long', type=float, default = -78.16111,  help='Longitude of weather data')
parser.add_argument('--start_date', type=str, default = '2025-01-01', help='Start date of selected data')
parser.add_argument('--end_date', type=str, default = '2025-01-03', help='End date of selected data')
parser.add_argument('--tz', type=str, default = 'UTC', help='Timezone of selected data')
args = parser.parse_args()


# Accessing the arguments
logging.info(f"Using the following config for data extraction:")
logging.info(f"Environment: {args.env}")
logging.info(f"Load Type: {args.load_type}")
logging.info(f"Latitude: {args.lat}")
logging.info(f"Longitude: {args.long}")
logging.info(f"Start Date: {args.start_date}")
logging.info(f"End Date: {args.end_date}")
logging.info(f"Timezone: {args.tz}")


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

    endpoint = r"https://api.open-meteo.com/v1/forecast"
    
    query_params = {
        "latitude": lat,
        "longitude": long,
        "hourly": ",".join(requested_fields_hourly),
        "start_date": start_date,
        "end_date": end_date,
        "timezone": tz
    }

    # TODO try except 
    response = requests.get(endpoint, query_params)
    data = pd.json_normalize(response.json())
    

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

    
    return df_out

def main(db_conn_str = '../duckdb/dev_db.duckdb', load_type=args.load_type, lat = args.lat, long = args.long, start_date = args.start_date, end_date = args.end_date, tz=args.tz):

    # extract
    extracted_data = get_meteo_data(
        lat,
        long,
        start_date,
        end_date,
        tz
    )
    logging.info("Extraced meteo data")

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
