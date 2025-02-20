WITH t AS (
    SELECT * FROM {{ ref("Region") }}
)

SELECT * FROM t