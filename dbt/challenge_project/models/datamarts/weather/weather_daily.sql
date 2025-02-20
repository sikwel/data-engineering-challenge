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
),
agg AS(
    SELECT 
        "geohash"
        ,"sales_territory_key"
        ,"date"
        ,AVG(temperature) AS "temperature_avg"
        ,AVG(relative_humidity) AS "relative_humidity_avg"
        ,AVG(rain) AS "rain_avg"
        ,AVG(wind_speed) AS "wind_speed_avg"
        ,AVG(surface_pressure) AS "surface_pressure_avg"
        ,MIN(data_time_stamp) AS "data_time_stamp_earliest"
        ,MAX(data_time_stamp) AS "data_time_stamp_latest"
    FROM t
    GROUP BY "geohash", "sales_territory_key", "date"

)

SELECT * FROM agg

