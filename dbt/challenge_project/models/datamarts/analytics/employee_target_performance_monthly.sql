WITH 
tar AS (
    SELECT
        "employee_id"
        ,"target_dollar"
        ,"target_year_month"
    FROM 
        {{ref("sales_targets")}} 
),
sal AS (
    SELECT 
        "order_date_year_month"
        ,"employee_key"
        ,"employee_id"
        ,"employee_name_full"
        ,"employee_title"
        ,"sales_dollar"
    FROM 
        {{ref("sales_all")}}
),
sal_monthly AS (
    SELECT 
        "order_date_year_month"
        ,"employee_key"
        ,"employee_id"
        ,"employee_name_full"
        ,"employee_title"
        ,SUM("sales_dollar") AS "sum_sales_dollar" -- if you don't have sales for a month, this should be 0
    FROM 
        sal
    GROUP BY 
        "order_date_year_month"
        ,"employee_key"
        ,"employee_id"
        ,"employee_name_full"
        ,"employee_title"
)

SELECT 
    tar."target_year_month"
    ,tar."employee_id"
    ,sal_monthly."employee_key"
    ,sal_monthly."employee_name_full"
    ,sal_monthly."employee_title"
    ,tar."target_dollar"
    ,COALESCE(sal_monthly."sum_sales_dollar", 0) AS "sum_sales_dollar" -- if you don't have sales for a month, this should be 0
    ,COALESCE(sal_monthly."sum_sales_dollar", 0) - tar."target_dollar" AS "sales_delta_to_target_abs_dollar"
    ,100*(COALESCE(sal_monthly."sum_sales_dollar", 0) - tar."target_dollar") / tar."target_dollar" AS "sales_delta_to_target_relative_percent"
FROM tar
LEFT JOIN sal_monthly ON tar."employee_id" = sal_monthly."employee_id" AND tar."target_year_month" = sal_monthly."order_date_year_month"
WHERE 1=1 
AND sal_monthly."employee_title" = 'Sales Representative' -- lets only consider "regular folks" as we do not know, how the managers have to be assessed
AND tar."target_year_month" <= '2020-05' -- lets only consider targets up to May 2020, since our sales data seems to end there
ORDER BY tar."target_year_month" DESC, sal_monthly."employee_key"