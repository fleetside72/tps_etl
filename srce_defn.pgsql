WITH
ext AS (
SELECT 
    srce
    ,defn->'unique_constraint'->>'fields'
    ,ARRAY(SELECT ae.e::text[] FROM jsonb_array_elements_text(defn->'unique_constraint'->'fields') ae(e)) txa
FROM
    tps.srce
)


SELECT
    t.srce
    ,jsonb_pretty(t.rec)
    ,jsonb_pretty(public.jsonb_extract(rec,txa))
FROM
    tps.trans t
    INNER JOIN ext ON
        t.srce = ext.srce