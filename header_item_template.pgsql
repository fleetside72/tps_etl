DO $f$

DECLARE _j jsonb;
DECLARE _m text;

BEGIN

_j := $${"header":{"vendor":"Target","date":"10/12/2017","instrument":"Discover Card","module":"hdrio","total":47.74,"location":"Stow, OH","transaction":"purchase","offset":"dcard"},"item":[{"vend item":"HERBAL","amt":7.99,"account":"home supplies","item":"shampoo","reason":"hygiene"},{"vend item":"HERBAL","amt":7.99,"account":"home supplies","item":"conditioner","reason":"hygiene"},{"vend item":"BUILDING SET","amt":28.74,"account":"recreation","item":"legos","reason":"toys","qty":6,"uom":"ea"},{"vend item":"OH TAX","amt":3.02,"account":"sales tax","item":"sales tax","reason":"sales tax","rate":"0.0675"}]}$$;

WITH
j AS (
    SELECT
        _j  jb
)

--------build a duplicating cross join table------------------

    ,os AS (
        SELECT
            flag, 
            sign,
            x.offs
        FROM
            j
            JOIN LATERAL
            (
                VALUES
                ('ITEM',1,null),
                ('OFFSET',-1,j.jb->'header'->>'offset')
            ) x (flag, sign, offs) ON TRUE
    )


------------do the cross join against all the item elements-------------------

,build AS (
SELECT
    array['item',rn::text]::text jpath
    ,COALESCE(os.offs,ae.e->>'account') acct
    ,(ae.e->>'amt')::numeric * os.sign amount
FROM
    j
    LEFT JOIN LATERAL JSONB_ARRAY_ELEMENTS(J.JB->'item') WITH ORDINALITY ae(e,rn) ON TRUE
    CROSS JOIN os
ORDER BY
    ae.rn ASC,
    os.flag ASC
)

-------------re-aggregate the items into a single array point called 'gl'---------------

,agg AS (
SELECT
    jsonb_build_object('gl',jsonb_agg(row_to_json(b))) gl
FROM
    build b
)

------------take the new 'gl' with array key-value pair and combine it with the original---------------

SELECT
    jsonb_pretty(agg.gl||j.jb)
INTO
    _m
FROM
    agg
    CROSS JOIN j;

    RAISE NOTICE '%', _m;
    
END
$f$