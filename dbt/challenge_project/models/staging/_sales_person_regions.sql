WITH t AS (
    SELECT * FROM {{ ref("SalespersonRegion") }}
)

SELECT * FROM t