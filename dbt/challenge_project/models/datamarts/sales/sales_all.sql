SELECT
    "sales_order_number",
    "order_date",
    "product_key",
    "reseller_key",
    "employee_key",
    "sales_territory_key",
    "quantity",
    "unit_price_dollar", 
    "sales_dollar",
    "cost_dollar"
FROM 
    {{ref("sales_cleaned")}}

ORDER BY "order_date" DESC
    