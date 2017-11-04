
--this is a dynamic approach that dumps all keys into the json except several that are required which it extracts
WITH
expand_gl AS (
SELECT
    id,
    ARRAY['GL',rn::text] json_path,
    post_stmp,
    (a.i->>'amt')::numeric amount,
    a.i->>'account' account,
    j.rec->'header'->>'date' tran_date,
    j.rec->'header'->>'vendor' vendor,
    (a.i - '{amt,account,date}'::text[])||j.rec->'header' as therest
FROM
    evt.log j
    LEFT JOIN LATERAL JSONB_ARRAY_ELEMENTS(j.rec->'GL') WITH ORDINALITY a(i, rn) ON TRUE
)
,gl_agg AS (
SELECT 
    id
    , tran_date
    , vendor
    , SUM(amount) amt
    , ROUND(SUM(amount) FILTER (WHERE account = 'dcard'),2) dr
FROM    
    expand_gl 
GROUP BY 
    id
    , tran_date
    , vendor     
ORDER BY 
    id asc
)
SELECT id, tran_date, vendor, amt, dr, sum(dr) over(ORDER BY id) FROM gl_agg