\timing

/*--------------------------------------------------
maintain statment level triggers to update a master log of keys
* table based listing
* composite type maintenance

potential updates sources/events
* tps.trans insert
* tps.trans re-map
--------------------------------------------------*/

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