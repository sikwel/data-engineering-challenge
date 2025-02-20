WITH t AS (
    SELECT * FROM {{ ref("mapping_region_coords") }}
)

SELECT * FROM t