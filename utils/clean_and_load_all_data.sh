#!/bin/bash
# This calls our data extraction and fills it up the DB with all the data we need

python "./extract_meteo/main.py" --env 'dev' --load_type 'full' --lat 34.31295 --long -78.16111 --start_date '2017-07-01' --end_date '2020-05-31' --tz 'GMT+1'
python "./extract_meteo/main.py" --env 'dev' --load_type 'incremental' --lat 42.21561 --long -79.83422 --start_date '2017-07-01' --end_date '2020-05-31' --tz 'GMT+1'
python "./extract_meteo/main.py" --env 'dev' --load_type 'incremental' --lat 43.2342 --long -86.2506 --start_date '2017-07-01' --end_date '2020-05-31' --tz 'GMT+1'
python "./extract_meteo/main.py" --env 'dev' --load_type 'incremental' --lat 40.19896 --long -79.52087 --start_date '2017-07-01' --end_date '2020-05-31' --tz 'GMT+1'
python "./extract_meteo/main.py" --env 'dev' --load_type 'incremental' --lat 38.88067 --long -76.98998 --start_date '2017-07-01' --end_date '2020-05-31' --tz 'GMT+1'
python "./extract_meteo/main.py" --env 'dev' --load_type 'incremental' --lat 60.10867 --long -113.64258 --start_date '2017-07-01' --end_date '2020-05-31' --tz 'GMT+1'
python "./extract_meteo/main.py" --env 'dev' --load_type 'incremental' --lat 46.0 --long 2.0 --start_date '2017-07-01' --end_date '2020-05-31' --tz 'GMT+1'
python "./extract_meteo/main.py" --env 'dev' --load_type 'incremental' --lat 51.5 --long 10.5 --start_date '2017-07-01' --end_date '2020-05-31' --tz 'GMT+1'
python "./extract_meteo/main.py" --env 'dev' --load_type 'incremental' --lat -25.0 --long 135.0 --start_date '2017-07-01' --end_date '2020-05-31' --tz 'GMT+1'
python "./extract_meteo/main.py" --env 'dev' --load_type 'incremental' --lat  54.75844 --long -2.69531 --start_date '2017-07-01' --end_date '2020-05-31' --tz 'GMT+1'