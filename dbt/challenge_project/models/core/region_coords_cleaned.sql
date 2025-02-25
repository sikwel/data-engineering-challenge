WITH t AS ( 
    SELECT
        "SalesTerritoryKey" AS "sales_territory_key"
        ,"Latitude" AS "latitude"
        ,"Longitude" AS "longitude"
        ,"Geohash" AS "geohash"
    FROM
        {{ref(("_region_coords"))}}
)

SELECT * FROM t