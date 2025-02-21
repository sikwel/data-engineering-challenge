WITH w AS (
    SELECT
        *
    FROM 
        {{ref("weather_daily")}}
),
s AS (
    SELECT
        *
    FROM
        {{ref("sales_agg_by_date_and_region")}}
)

SELECT 
    s.*
    ,w."temperature_avg"
    ,w."relative_humidity_avg"
    ,w."rain_avg"
    ,w."wind_speed_avg"
    ,w."surface_pressure_avg"
    
FROM s
INNER JOIN w ON w."sales_territory_key"=s."sales_territory_key" AND w."date" = s."order_date" -- lets only consider dates and regions, where we have sales and weather data