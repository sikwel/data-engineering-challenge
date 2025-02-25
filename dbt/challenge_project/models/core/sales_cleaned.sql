SELECT
    "SalesOrderNumber" AS "sales_order_number",
    STRPTIME("OrderDate", '%A, %B %d, %Y') AS "order_date",
    STRFTIME("order_date", '%Y-%m') AS "order_date_year_month",
    "ProductKey" AS "product_key",
    "ResellerKey" AS "reseller_key",
    "EmployeeKey" AS "employee_key",
    "SalesTerritoryKey" AS "sales_territory_key",
    "Quantity" AS "quantity",
    CAST(REPLACE(REPLACE("Unit Price", '$', ''), ',', '') AS FLOAT) as "unit_price_dollar", -- from STRING $2,404.42 to FLOAT 2404.42
    CAST(REPLACE(REPLACE("Sales", '$', ''), ',', '') AS FLOAT) as "sales_dollar",
    CAST(REPLACE(REPLACE("Cost", '$', ''), ',', '') AS FLOAT) as "cost_dollar"
    
FROM 
    {{ ref("_sales") }}