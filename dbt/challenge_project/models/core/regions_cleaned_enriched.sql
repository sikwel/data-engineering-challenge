WITH r AS (
    SELECT 
        "SalesTerritoryKey" AS "sales_territory_key",
        "Region" AS "region",
        "Country" AS "country",
        "Group" AS "group",
    FROM 
        {{ ref("_regions") }}
),

c AS (
    SELECT
        "sales_territory_key",
        "latitude",
        "longitude"
    FROM
        {{ref("region_coords_cleaned")}}
)

SELECT r.*, c."latitude" AS "region_latitude", c."longitude" AS "region_longitude" 
FROM r
LEFT JOIN c ON r."sales_territory_key" = c."sales_territory_key"