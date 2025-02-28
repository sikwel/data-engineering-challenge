WITH w AS (
    SELECT
        "sales_territory_key"
        ,"date"
        ,"temperature_avg"
        ,"relative_humidity_avg"
        ,"rain_avg"
        ,"wind_speed_avg"
        ,"surface_pressure_avg"
    FROM 
        {{ref("weather_daily")}}
),
o AS (
    SELECT
        
        "order_date"
        ,"sales_territory_key"
        ,COUNT(DISTINCT "sales_order_number") AS "cnt_distinct_orders"

        ,SUM("quantity_sum") AS "sum_quantity"
        ,AVG("quantity_sum") AS "avg_quantity"
        ,MAX("quantity_sum") AS "max_quantity"
        ,MIN("quantity_sum") AS "min_quantity"

        ,SUM("sales_dollar_sum") AS "sum_sales_dollar"
        ,AVG("sales_dollar_sum") AS "avg_sales_dollar"
        ,MAX("sales_dollar_sum") AS "max_sales_dollar"
        ,MIN("sales_dollar_sum") AS "min_sales_dollar"

        ,SUM("cost_dollar_sum") AS "sum_cost_dollar"
        ,AVG("cost_dollar_sum") AS "avg_cost_dollar"
        ,MAX("cost_dollar_sum") AS "max_cost_dollar"
        ,MIN("cost_dollar_sum") AS "min_cost_dollar"  
    FROM 
        {{ref("orders")}}

    GROUP BY "order_date", "sales_territory_key"
)

SELECT 
    w."date"
    ,w."sales_territory_key"
    ,w."temperature_avg"
    ,w."relative_humidity_avg"
    ,w."rain_avg"
    ,w."wind_speed_avg"
    ,w."surface_pressure_avg"
    ,COALESCE(o."cnt_distinct_orders",0) AS "cnt_distinct_orders"
    ,COALESCE(o."sum_quantity",0) AS "sum_quantity"
    ,COALESCE(o."avg_quantity",0) AS "avg_quantity"
    ,COALESCE(o."max_quantity",0) AS "max_quantity"
    ,COALESCE(o."min_quantity",0) AS "min_quantity"
    ,COALESCE(o."sum_sales_dollar",0) AS "sum_sales_dollar"
    ,COALESCE(o."avg_sales_dollar",0) AS "avg_sales_dollar"
    ,COALESCE(o."max_sales_dollar",0) AS "max_sales_dollar"
    ,COALESCE(o."min_sales_dollar",0) AS "min_sales_dollar"
    
    
FROM w
LEFT JOIN o ON o."sales_territory_key"=w."sales_territory_key" AND o."order_date" = w."date"
ORDER BY o."order_date" DESC, o."sales_territory_key" ASC