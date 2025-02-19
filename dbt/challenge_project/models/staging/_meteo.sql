{{ config(materialized='table') }}

with meteo_data as (

    SELECT *
    FROM dev_db.main.weather_data_hourly

)

select *
from meteo_data
