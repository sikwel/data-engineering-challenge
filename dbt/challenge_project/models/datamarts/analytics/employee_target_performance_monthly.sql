WITH 
emp AS (
    SELECT 
        "employee_key"
        ,"employee_id"
        ,"employee_name_full"
        ,"employee_title"
        ,"employee_email"
    FROM 
        {{ref("sales_people")}}
),
tar AS (
    SELECT
        "employee_id"
        ,"target_dollar"
        ,"target_year_month"
    FROM 
        {{ref("sales_targets_by_date_and_person")}} 
),
sal AS (
    SELECT 
        "sales_order_number"
        ,"order_date"
        ,"order_date_year_month"
        ,"employee_key"
        ,"sales_dollar"
    FROM 
        {{ref("sales_all")}}
),
sal_monthly AS (
    SELECT 
        "employee_key"
        ,"order_date_year_month"
        ,SUM("sales_dollar") AS "sum_sales_dollar" -- if you don't have sales for a month, this should be 0
    FROM 
        sal
    GROUP BY 
        "employee_key", "order_date_year_month"
)

SELECT 
    tar."target_year_month"
    ,tar."employee_id"
    ,emp."employee_key"
    ,emp."employee_name_full"
    ,emp."employee_title"
    ,tar."target_dollar"
    ,COALESCE(sal_monthly."sum_sales_dollar", 0) AS "sum_sales_dollar" -- if you don't have sales for a month, this should be 0
    ,COALESCE(sal_monthly."sum_sales_dollar", 0) - tar."target_dollar" AS "sales_delta_to_target_abs_dollar"
    ,100*(COALESCE(sal_monthly."sum_sales_dollar", 0) - tar."target_dollar") / tar."target_dollar" AS "sales_delta_to_target_relative_percent"
FROM tar
LEFT JOIN emp ON tar."employee_id" = emp."employee_id"
LEFT JOIN sal_monthly ON emp."employee_key" = sal_monthly."employee_key" AND tar."target_year_month" = sal_monthly."order_date_year_month"
WHERE 1=1 
AND emp."employee_title" != 'Director of Sales' -- lets exclude the director of sales. His targets have to be considered against the aggregate sales of all other sales people
AND tar."target_year_month" <= '2020-05' -- lets only consider targets up to May 2020, since our sales data seems to end there
ORDER BY tar."target_year_month" DESC, emp."employee_key"
