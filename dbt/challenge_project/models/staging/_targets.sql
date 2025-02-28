WITH t AS (
    SELECT * FROM {{ ref("Targets") }}
)

SELECT * FROM t