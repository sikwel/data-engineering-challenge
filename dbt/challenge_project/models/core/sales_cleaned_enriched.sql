WITH
sales AS (
    SELECT
        "sales_order_number"
        ,"order_date"
        ,"order_date_year_month"
        ,"product_key"
        ,"reseller_key"
        ,"employee_key"
        ,"sales_territory_key"
        ,"quantity"
        ,"unit_price_dollar"
        ,"sales_dollar"
        ,"cost_dollar"
    FROM 
        {{ref("sales_cleaned")}}
),
prod AS (
    SELECT
        "product_key"
        ,"product_name"
        ,"category" AS "product_category"
        ,"subcategory" AS "product_subcategory"
        ,"standard_cost" AS "product_standard_cost"
        ,"color" AS "product_color"
    FROM 
        {{ref("products_cleaned")}}
),
reseller AS (
    SELECT
        "reseller_key"
        ,"reseller_business_type"
        ,"reseller_name"
        ,"reseller_city"
        ,"reseller_state_province"
        ,"reseller_country"
    FROM 
        {{ref("resellers_cleaned")}}
),
employees AS (
    SELECT
        "employee_key"
        ,"employee_id"
        ,"employee_name_full"
        ,"employee_title"
        ,"employee_email"
    FROM 
        {{ref("sales_people_cleaned")}}
)

SELECT
        sales."sales_order_number"
        ,sales."order_date"
        ,sales."order_date_year_month"
        ,sales."product_key"
        ,sales."reseller_key"
        ,sales."employee_key"
        ,sales."sales_territory_key"
        ,sales."quantity"
        ,sales."unit_price_dollar"
        ,sales."sales_dollar"
        ,sales."cost_dollar"
        ,prod."product_name"
        ,prod."product_category"
        ,prod."product_subcategory"
        ,prod."product_standard_cost"
        ,prod."product_color"
        ,reseller."reseller_business_type"
        ,reseller."reseller_name"
        ,reseller."reseller_city"
        ,reseller."reseller_state_province"
        ,reseller."reseller_country"
        ,employees."employee_id"
        ,employees."employee_name_full"
        ,employees."employee_title"
        ,employees."employee_email"
FROM sales
LEFT JOIN prod ON sales."product_key" = prod."product_key"
LEFT JOIN reseller ON sales."reseller_key" = reseller."reseller_key"
LEFT JOIN employees ON employees."employee_key" = sales."employee_key"
