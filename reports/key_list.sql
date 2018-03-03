\timing

WITH ok AS (
    SELECT
        srce,
        ok.k,
        jsonb_typeof(allj->ok.k) typeof,
        COUNT(*)
    FROM
        tps.trans
        JOIN LATERAL jsonb_object_keys(allj) ok(k) ON TRUE
    GROUP BY   
        srce,
        ok.k,
        jsonb_typeof(allj->ok.k)
    ORDER BY 
        srce
)
SELECT
    srce
    ,k
    ,typeof
FROM
    ok