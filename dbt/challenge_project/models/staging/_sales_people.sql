WITH t AS (
    SELECT * FROM {{ ref("Salesperson") }}
)

SELECT * FROM t