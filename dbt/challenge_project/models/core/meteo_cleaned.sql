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

    WHERE 1=1
    -- the sales-data time-frame seemts to exceeds availablity of historical weather data, so NULL values exist
    -- depending on usecase, i could see several ways to tackle this problem (check during ingestion, dbt test, or simple filter it here)
    -- lets only consider complete data sets!
    AND "temperature" IS NOT NULL
    AND "relative_humidity" IS NOT NULL
    AND "rain" IS NOT NULL
    AND "weather_code" IS NOT NULL
    AND "wind_speed" IS NOT NULL
    AND "surface_pressure" IS NOT NULL

    ORDER BY data_time_stamp DESC -- to see imidiately when last data injection has been made   

)

SELECT * FROM t