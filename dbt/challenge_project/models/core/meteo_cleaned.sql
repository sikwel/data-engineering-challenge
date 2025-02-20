-- dtypes are already enforced in DB
-- names are already are fine
-- let's explicitly load here, since we use SELECT * in the staging layer

WITH t as (
    SELECT
        "geohash"
        ,"latitude"	
        ,"longitude"	
        ,"timezone"
        ,"time" as "date_time"
        ,CAST("time" AS DATE) as "date"
        ,"temperature"	
        ,"relative_humidity"	
        ,"rain"	
        ,"weather_code"	
        ,"wind_speed"	
        ,"surface_pressure"	
        ,"data_time_stamp"

    FROM 
        {{ ref("_meteo") }}

    ORDER BY data_time_stamp DESC -- for fun ... and to see imidiately when last data injection has been made

    # TODO: either filter away NANs here or do dbt test
)

SELECT * FROM t