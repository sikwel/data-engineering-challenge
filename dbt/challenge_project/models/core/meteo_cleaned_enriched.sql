-- dtypes are already enforced in DB
-- names are already are fine
-- let's explicitly load here, since we use SELECT * in the staging layer

WITH m as (
    SELECT
        "geohash"
        ,"latitude"	
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
        {{ ref("meteo_cleaned") }}

),

r AS (
    SELECT
        "sales_territory_key",
        "geohash"        
    FROM 
        {{ ref("regions_cleaned_enriched") }}
)

SELECT m.*, r."sales_territory_key" 
FROM m
LEFT JOIN r ON r."geohash" = m."geohash"