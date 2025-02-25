WITH 
p AS(
    SELECT
        "product_key"
        ,"product"
        ,"standard_cost"
        ,"color"
        ,"subcategory"
        ,"category"
        ,"background_color_format"
        ,"font_color_format"
    FROM 
        {{ref("products")}}
),
s AS (
    SELECT
        "order_date"
        ,"order_date_year_month"
        ,"product_key"
        ,"quantity"
        ,"unit_price_dollar"
        ,"sales_dollar"
        ,"cost_dollar"
    FROM 
        {{ref("sales_cleaned")}}
),
joined AS (
    SELECT
        s."order_date"
        ,s."order_date_year_month"
        ,s."product_key"
        ,s."quantity"
        ,s."unit_price_dollar"
        ,s."sales_dollar"
        ,s."cost_dollar"
        ,p."product"
        ,p."standard_cost"
        ,p."color"
        ,p."subcategory"
        ,p."category"
        ,p."background_color_format"
        ,p."font_color_format"
    FROM 
        s
    LEFT JOIN p ON s."product_key" = p."product_key"
)

SELECT 
    "product_key"
    ,"product"
    ,"standard_cost"
    ,"color"
    ,"subcategory"
    ,"category"
    ,"background_color_format"
    ,"font_color_format"
    ,COUNT("order_date") AS "count_orders"
    ,SUM("quantity") AS "quantity_sum"
    ,AVG("quantity") AS "quanitiy_avg_per_order"
    ,MAX("quantity") AS "quanitiy_max"
    ,MIN("quantity") AS "quanitiy_min"
    ,SUM("sales_dollar") AS "sales_sum_dollar"
    ,AVG("sales_dollar") AS "sales_avg_per_order_dollar"
    ,MAX("sales_dollar") AS "sales_max_dollar"
    ,MIN("sales_dollar") AS "sales_min_dollar"
FROM 
    joined
GROUP BY
    "product_key"
    ,"product"
    ,"standard_cost"
    ,"color"
    ,"subcategory"
    ,"category"
    ,"background_color_format"
    ,"font_color_format"