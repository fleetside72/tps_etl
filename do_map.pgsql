
WITH

--------------------apply regex operations to transactions-----------------------------------------------------------------------------------

rx AS (
SELECT 
    m.srce,
    m.target,
    t.id,
    jsonb_build_object(
        e.v ->> 'key',
        (t.rec #> ((e.v ->> 'key')::text[]))
    ) AS rkey,
    jsonb_build_object(
        e.v->>'field',
        CASE WHEN array_upper(mt.mt,1)=1 
            THEN to_json(mt.mt[1]) 
            ELSE array_to_json(mt.mt) 
        END
    ) retval,
    m.seq
FROM 
    tps.map_rm m
    LEFT JOIN LATERAL jsonb_array_elements(m.regex->'where') w(v) ON TRUE
    JOIN tps.trans t ON 
        t.srce = m.srce AND
        t.rec @> w.v
    LEFT JOIN LATERAL jsonb_array_elements(m.regex->'defn') WITH ORDINALITY e(v, rn) ON true
    LEFT JOIN LATERAL regexp_matches(t.rec #>> ((e.v ->> 'key')::text[]), e.v ->> 'regex'::text) WITH ORDINALITY mt(mt, rn) ON true
WHERE
    t.srce = 'PNCC'     
ORDER BY 
    m.srce, 
    m.seq,
    m.target, 
    t.id, 
    e.rn
),

----------aggregate regex back to the target level (may be several targets per row)---------------------------------------------------------------


agg_rx AS (
    SELECT 
        rx.srce,
        rx.target,
        rx.id, 
        tps.jsonb_concat_obj(rx.rkey) rkey,
        tps.jsonb_concat_obj(rx.retval) AS retval,
        rx.seq
    FROM 
        --unwrap json instruction and apply regex using a count per original line for re-aggregation
        --need to look at integrating regex option like 'g' that would then need aggegated back as an array, or adding the ordinality number to the title
        rx
    GROUP BY 
        rx.srce, 
        rx.target, 
        rx.id,
        rx.seq
)


-------------aggregate all targets back to row level (id)------------------------------------------------------------------------------------------------


    SELECT 
        u.srce,
        u.id,
        string_agg(u.target,',') target,
        jsonb_pretty(tps.jsonb_concat_obj(coalesce(v.map,'{}'::jsonb) ORDER BY seq )) map,
        jsonb_pretty(tps.jsonb_concat_obj(u.retval||coalesce(v.map,'{}'::jsonb) ORDER BY seq)) comb
    FROM 	
        --re-aggregate return values and explude any records where one or more regex failed with a null result
        agg_rx u
        LEFT OUTER JOIN tps.map_rv v ON
            v.target = u.target AND
            v.srce = u.srce AND
            v.retval <@ u.retval
    GROUP BY
        u.srce,
        u.id
    LIMIT 1000