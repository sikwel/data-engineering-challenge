WITH
t AS (
    SELECT 
        "employee_id"
        ,"target_dollar"
        ,"target_year_month"
    FROM 
        {{ref("targets_cleaned")}}
),
e AS (
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
    t."employee_id"
    ,e."employee_key"
    ,t."target_dollar"
    ,t."target_year_month"
    ,e."employee_name_full"
    ,e."employee_title"
    ,e."employee_email"
FROM t
LEFT JOIN e ON t."employee_id" = e."employee_id"


