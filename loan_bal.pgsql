\timing
SELECT 
    r.*,
    SUM(r."Advances"+r."Adjustments"-r."Payments") OVER (PARTITION BY "Loan#" ORDER BY r."Post Date" asc ,rec->>'id' asc, r."Reference #" asc)
FROM 
    tps.trans
    LEFT JOIN LATERAL jsonb_populate_record(null::tps.pnco, rec) r ON TRUE
WHERE 
    rec @> '{"Loan#":"606780281"}' 
ORDER BY 
    r."Loan#"
    ,r."Post Date" ASC
    ,rec->>'id' ASC
    ,r."Reference #" ASC