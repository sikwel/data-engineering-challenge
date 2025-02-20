-- dtypes are already enforced in DB
-- names are already are fine
-- let's explicitly load here, since we use SELECT * in the staging layer

WITH t as (
    SELECT
        "latitude"	
        ,"longitude"	
        ,"timezone"
        ,"time"	
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
)

SELECT * FROM T