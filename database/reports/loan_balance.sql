\timing
SELECT 
    r.*,
    SUM(r."Advances"+r."Adjustments"-r."Payments") OVER (PARTITION BY "Loan#" ORDER BY r."Post Date" asc, r."Reference #" asc)
FROM 
    tpsv.pnco_default r
WHERE 
    "Loan#" = '606780191'
ORDER BY 
    r."Loan#"
    ,r."Post Date" ASC
    ,r."Reference #" ASC