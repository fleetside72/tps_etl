
WITH j AS (
SELECT
    id,
    post_stmp,
    rec as r
FROM
    evt.log
)

--this is a dynamic approach that dumps all keys into the json except several that are required which it extracts
SELECT
    id,
    ARRAY['GL',rn::text] json_path,
    post_stmp,
    a.i->>'amt' amount,
    a.i->>'account' account,
    a.i->>'date' tran_date,
    a.i - '{amt,account,date}'::text[] as therest
FROM
    j
    LEFT JOIN LATERAL JSONB_ARRAY_ELEMENTS(j.r->'GL') WITH ORDINALITY a(i, rn) ON TRUE