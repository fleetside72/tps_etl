
SELECT 
    id,
    rec->>'id',
    r.*,
    CASE "Schedule#"
        WHEN '02IN Raw Material' THEN 13097563.42
        WHEN '03IN Finished Goods' THEN 35790696.52
        ELSE 0
    END + SUM("Sales"+"Credits & Adjustments"-"Gross Collections") OVER (ORDER BY "PostDate" ASC, rec->>'id' ASC)
FROM 
    tps.trans
    LEFT JOIN LATERAL jsonb_populate_record(null::tps.pncl, rec) r ON TRUE
WHERE 
    rec @> '{"Schedule#":"01AR"}' 
ORDER BY 
    r."PostDate" asc