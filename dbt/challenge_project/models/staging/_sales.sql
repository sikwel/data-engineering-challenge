WITH t AS (
    SELECT * FROM {{ ref("Sales") }}
)

SELECT * FROM t