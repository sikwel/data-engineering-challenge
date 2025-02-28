WITH t AS (
    SELECT
        "geohash"
        ,"sales_territory_key"
        ,"latitude"	
        ,"longitude"	
        ,"timezone"
        ,"date_time"	
        ,"date"	
        ,"temperature"	
        ,"relative_humidity"	
        ,"rain"	
        ,"weather_code"	
        ,"wind_speed"	
        ,"surface_pressure"	
        ,"data_time_stamp"
    FROM 
        {{ ref("meteo_cleaned_enriched") }}
)

SELECT * FROM t

