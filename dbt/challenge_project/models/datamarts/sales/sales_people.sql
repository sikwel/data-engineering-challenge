SELECT 
    "employee_key"
    ,"employee_id"
    ,"employee_name_full"
    ,"employee_title"
    ,"employee_email"
FROM 
    {{ref("sales_people_cleaned")}}