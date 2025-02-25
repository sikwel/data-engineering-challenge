SELECT 
    "employee_id"
    ,"target_dollar"
    ,"target_year_month"
FROM {{ref("targets_cleaned_enriched")}}
