WITH t AS (
    SELECT * FROM {{ ref("Product") }}
)

SELECT * FROM t