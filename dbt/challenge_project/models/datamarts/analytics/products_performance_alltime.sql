SELECT 
    "product_key"
    ,"product_name"
    ,"product_standard_cost"
    ,"product_color"
    ,"product_subcategory"
    ,"product_category"
    ,COUNT(DISTINCT "sales_order_number") AS "cnt_orders_total"
    ,SUM("quantity") AS "quantity_sum"
    ,AVG("quantity") AS "quantity_avg_order"
    ,MAX("quantity") AS "quanitity_max_per_order"
    ,SUM("sales_dollar") AS "sales_sum_dollar"
    ,AVG("sales_dollar") AS "sales_avg_per_order_dollar"
    ,MAX("sales_dollar") AS "sales_max_dollar"
    ,MIN("sales_dollar") AS "sales_min_dollar"
FROM 
    {{ref("sales_all")}}
GROUP BY
    "product_key"
    ,"product_name"
    ,"product_standard_cost"
    ,"product_color"
    ,"product_subcategory"
    ,"product_category"