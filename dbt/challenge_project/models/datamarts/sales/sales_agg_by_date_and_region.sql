SELECT
    
    "order_date",
    "sales_territory_key",

    COUNT("sales_order_number") AS "cnt_orders",

    SUM("quantity") AS "sum_quantity",
    AVG("quantity") AS "avg_quantity",
    MAX("quantity") AS "max_quantity",
    MIN("quantity") AS "min_quantity",

    SUM("unit_price_dollar") AS "sum_unit_price_dollar",
    AVG("unit_price_dollar") AS "avg_unit_price_dollar",
    MAX("unit_price_dollar") AS "max_unit_price_dollar",
    MIN("unit_price_dollar") AS "min_unit_price_dollar",

    SUM("sales_dollar") AS "sum_sales_dollar",
    AVG("sales_dollar") AS "avg_sales_dollar",
    MAX("sales_dollar") AS "max_sales_dollar",
    MIN("sales_dollar") AS "min_sales_dollar",

    SUM("cost_dollar") AS "sum_cost_dollar",
    AVG("cost_dollar") AS "avg_cost_dollar",
    MAX("cost_dollar") AS "max_cost_dollar",
    MIN("cost_dollar") AS "min_cost_dollar"

FROM 
    {{ref("sales_cleaned")}}

GROUP BY "order_date", "sales_territory_key"


ORDER BY "order_date" DESC
    