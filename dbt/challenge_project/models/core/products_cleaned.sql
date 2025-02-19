WITH t AS (
    SELECT 
        "ProductKey" AS "product_key",
        "Product" AS "product",
        CAST(REPLACE(REPLACE("Standard Cost", '$', ''), ',', '') AS FLOAT) AS "standard_cost", -- from STRING: $1,435.56 to FLOAT: 1435.56
        "Color" AS "color",
        "Subcategory" AS "subcategory",
        "Category" AS "category",
        "Background Color Format" AS "background_color_format",
        "Font Color Format" AS "font_color_format"
    FROM 
        {{ ref("_products") }}
)

SELECT * FROM t