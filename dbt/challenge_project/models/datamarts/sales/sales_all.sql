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
        ,"product_name"
        ,"product_category"
        ,"product_subcategory"
        ,"product_standard_cost"
        ,"product_color"
        ,"reseller_business_type"
        ,"reseller_name"
        ,"reseller_city"
        ,"reseller_state_province"
        ,"reseller_country"
        ,"employee_name_full"
        ,"employee_title"
        ,"employee_email"
        ,"employee_id"
FROM 
    {{ref("sales_cleaned_enriched")}}

ORDER BY "order_date" DESC
    