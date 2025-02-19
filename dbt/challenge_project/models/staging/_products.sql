WITH t AS (
    SELECT 
        "ProductKey",
        "Product",
        "Standard Cost",
        "Color",
        "Subcategory",
        "Category",
        "Background Color Format",
        "Font Color Format"
    FROM 
        {{ ref("Product") }}
)

SELECT * FROM t