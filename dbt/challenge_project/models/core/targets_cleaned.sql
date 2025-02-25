SELECT 
    "EmployeeID" AS "employee_id"
    ,CAST(REPLACE(REPLACE("Target", '$', ''), ',', '') AS FLOAT) AS "target_dollar"
    ,STRFTIME(STRPTIME("TargetMonth", '%A, %B %d, %Y'), '%Y-%m') AS target_year_month
FROM {{ref("_targets")}}
