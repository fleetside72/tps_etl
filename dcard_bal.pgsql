\timing
SELECT 
    r.*,
    rec->'id',
    SUM(r."Amount") OVER (PARTITION BY srce ORDER BY r."Post Date" asc , rec->>'id' asc, r."Description") + 1061.1 + 22.40
FROM 
    tps.trans
    LEFT JOIN LATERAL jsonb_populate_record(null::tps.dcard, rec) r ON TRUE
WHERE 
    srce = 'DCARD'
ORDER BY 
    r."Post Date" asc
    ,rEC->>'id' asc