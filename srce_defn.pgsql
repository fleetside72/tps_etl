\timing
/*
WITH
ext AS (
SELECT 
    srce
    ,defn->'unique_constraint'->>'fields'
    ,ARRAY(SELECT ae.e::text[] FROM jsonb_array_elements_text(defn->'unique_constraint'->'fields') ae(e)) text_array
FROM
    tps.srce
    --add where clause for targeted source
)
*/

SELECT COUNT(*) FROM
(
SELECT DISTINCT
    t.srce
    ,(SELECT JSONB_OBJECT_agg(ae.e,rec #> ae.e::text[]) FROM jsonb_array_elements_text(defn->'unique_constraint'->'fields') ae(e)) ja
FROM
    tps.trans t
    INNER JOIN tps.srce s ON
        s.srce = t.srce
) X