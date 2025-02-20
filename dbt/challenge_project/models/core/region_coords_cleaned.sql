WITH t AS ( 
    SELECT
        -- omg ... this should be dealt with in seed config, but i was too weak to pull it off
        list_extract(str_split_regex("SalesTerritoryKey Latitude Longitude", '\t'), 1) AS "sales_territory_key",
        list_extract(str_split_regex("SalesTerritoryKey Latitude Longitude", '\t'), 2) AS "latitude",
        list_extract(str_split_regex("SalesTerritoryKey Latitude Longitude", '\t'), 3) AS "longitude"
    FROM
        {{(("mapping_region_coords"))}}
)

SELECT * FROM t