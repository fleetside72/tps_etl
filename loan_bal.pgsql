\timing
SELECT 
    r.*,
    SUM(r."Advances"+r."Adjustments"-r."Payments") OVER (ORDER BY r."Post Date" asc ,r."Reference #" asc)
FROM 
    tps.trans
    LEFT JOIN LATERAL jsonb_populate_record(null::tps.pnco, rec) r ON TRUE
WHERE 
    rec @> '{"Loan#":"606780191"}' 
ORDER BY 
    r."Post Date" asc
    ,r."Reference #" asc
