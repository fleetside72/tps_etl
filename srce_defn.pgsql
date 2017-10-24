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
    srce
    ,
    public.jsonb_extract(rec,txa)
FROM
    tps.trans
    INNER JOIN ext ON
        trans.srce = ext.srce