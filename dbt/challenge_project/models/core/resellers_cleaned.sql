SELECT
    "ResellerKey" AS "reseller_key"
    ,"Business Type" AS "reseller_business_type"
    ,"Reseller" AS "reseller_name"
    ,"City" AS "reseller_city"
    ,"State-Province" AS "reseller_state_province"
    ,"Country-Region" AS "reseller_country"
FROM {{ref("_resellers")}}