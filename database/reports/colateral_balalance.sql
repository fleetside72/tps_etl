SELECT 
    r.*
    ,CASE "Schedule#"
        WHEN '02IN Raw Material' THEN 13097563.42
        WHEN '03IN Finished Goods' THEN 35790696.52
        ELSE 0
    END + SUM("Sales"+"Credits & Adjustments"-"Gross Collections") OVER (PARTITION BY "Schedule#" ORDER BY "Schedule#" ASC, "PostDate" ASC) running_bal
    ,(LEAST("CollateralBalance" - "Ineligible Amount","MaxEligible")*("AdvanceRate"/100))::NUMERIC(20,2) qualified_collateral
    ,(("CollateralBalance" - "Ineligible Amount")*("AdvanceRate"/100))::NUMERIC(20,2) qualified_collateral_nl
FROM
    tpsv.pncl_default r
WHERE
    "Schedule#" = '01AR'
    --"Schedule#" = '02IN Raw Material'
    --"Schedule#" = '03IN Finished Goods'
ORDER BY 
    "Schedule#" asc
    ,r."PostDate" asc
    ,id