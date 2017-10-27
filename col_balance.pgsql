
SELECT 
    id
    ,rec->>'id'
    ,r.*
    ,CASE "Schedule#"
        WHEN '02IN Raw Material' THEN 13097563.42
        WHEN '03IN Finished Goods' THEN 35790696.52
        ELSE 0
    END + SUM("Sales"+"Credits & Adjustments"-"Gross Collections") OVER (PARTITION BY "Schedule#" ORDER BY "Schedule#" ASC, "PostDate" ASC, rec->>'id' ASC) running_bal
    ,(LEAST("CollateralBalance" - "Ineligible Amount","MaxEligible")*("AdvanceRate"/100))::NUMERIC(20,2) qualified_collateral
    ,(("CollateralBalance" - "Ineligible Amount")*("AdvanceRate"/100))::NUMERIC(20,2) qualified_collateral_nl
FROM 
    tps.trans
    LEFT JOIN LATERAL jsonb_populate_record(null::tps.pncl, rec) r ON TRUE
WHERE 
    srce = 'PNCL'
    --AND rec @> '{"Schedule#":"03IN Finished Goods"}' 
ORDER BY 
    "Schedule#" asc
    ,r."PostDate" asc
    ,rec->>'id' asc