WITH
mod AS (
SELECT 
    srce
    ,jsonb_pretty(defn) orig
    ,(defn - 'schemas')||
    --rebuild the schemas key value from below
    jsonb_build_object(
        'schemas'
        --aggregate all the new key values for a single soure
        ,jsonb_agg(
            --combine a new key 'name' with the columns for that name
            jsonb_build_object('name',k)||jsonb_build_object('columns',v)
        )
    ) rebuild
FROM 
    tps.srce
    LEFT JOIN LATERAL jsonb_each(defn->'schemas') WITH ORDINALITY je(k,v, rn) ON TRUE
GROUP BY
    srce
    ,defn
)
UPDATE
    tps.srce s
SET
    defn = rebuild
FROM
    mod
WHERE
    mod.srce = s.srce