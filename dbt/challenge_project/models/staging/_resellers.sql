WITH t AS (
    SELECT * FROM {{ ref("Reseller") }}
)

SELECT * FROM t