SELECT 
    "EmployeeKey" AS "employee_key"
    ,"EmployeeID" AS "employee_id"
    ,"Salesperson" AS "employee_name_full"
    ,"Title" AS "employee_title"
    ,"UPN" AS "employee_email"
FROM 
    {{ref("_sales_people")}}