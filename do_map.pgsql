
WITH

--------------------apply regex operations to transactions-----------------------------------------------------------------------------------

rx AS (
SELECT 
    m.srce,
    m.target,
    t.id,
    t.rec,
    jsonb_build_object(
        e.v ->> 'key',
        (t.rec #> ((e.v ->> 'key')::text[]))
    ) AS rkey,
    CASE regex->>'map'
        WHEN 'yes' THEN
            jsonb_build_object(
                e.v->>'field',
                CASE regex->>'function'
                    WHEN 'extract' THEN
                        CASE WHEN array_upper(mt.mt,1)=1 
                            THEN to_json(mt.mt[1])
                            ELSE array_to_json(mt.mt)
                        END::jsonb
                    WHEN 'replace' THEN
                        to_jsonb(rp.rp)
                    ELSE
                        '{}'::jsonb
                END
            )
        ELSE
            '{}'::jsonb
    END retval,
    CASE e.v->>'retain'
        WHEN 'y' THEN
            jsonb_build_object(
                e.v->>'field',
                CASE regex->>'function'
                    WHEN 'extract' THEN
                        CASE WHEN array_upper(mt.mt,1)=1 
                            THEN to_json(mt.mt[1])
                            ELSE array_to_json(mt.mt)
                        END::jsonb
                    WHEN 'replace' THEN
                        to_jsonb(rp.rp)
                    ELSE
                        '{}'::jsonb
                END
            )
        ELSE
            '{}'::jsonb
    END retain,
    m.seq
FROM 
    tps.map_rm m
    LEFT JOIN LATERAL jsonb_array_elements(m.regex->'where') w(v) ON TRUE
    INNER JOIN tps.trans t ON 
        t.srce = m.srce AND
        t.rec @> w.v
    LEFT JOIN LATERAL jsonb_array_elements(m.regex->'defn') WITH ORDINALITY e(v, rn) ON true
    LEFT JOIN LATERAL regexp_matches(t.rec #>> ((e.v ->> 'key')::text[]), e.v ->> 'regex'::text) WITH ORDINALITY mt(mt, rn) ON
        m.regex->>'function' = 'extract'
    LEFT JOIN LATERAL regexp_replace(t.rec #>> ((e.v ->> 'key')::text[]), e.v ->> 'regex'::text, e.v ->> 'replace'::text,e.v ->> 'flag'::text) WITH ORDINALITY rp(rp, rn) ON
        m.regex->>'function' = 'replace'
WHERE
    t.map IS NULL
ORDER BY 
    t.id DESC
),

----------aggregate regex back to the target level (may be several targets per row)---------------------------------------------------------------


agg_rx AS (
    SELECT 
        rx.srce,
        rx.target,
        rx.id, 
        rx.rec,
        tps.jsonb_concat_obj(rx.rkey) rkey,
        tps.jsonb_concat_obj(rx.retval) AS retval,
        tps.jsonb_concat_obj(rx.retain) AS retain,
        rx.seq
    FROM 
        --unwrap json instruction and apply regex using a count per original line for re-aggregation
        --need to look at integrating regex option like 'g' that would then need aggegated back as an array, or adding the ordinality number to the title
        rx
    GROUP BY 
        rx.srce, 
        rx.target, 
        rx.id,
        rx.rec,
        rx.seq
)


-------------aggregate all targets back to row level (id)------------------------------------------------------------------------------------------------

,agg_orig AS (
    SELECT 
        u.srce,
        u.id,
        u.rec,
        string_agg(u.target,',') target,
        tps.jsonb_concat_obj(u.retval) retval,
        tps.jsonb_concat_obj(u.retain) retain,
        tps.jsonb_concat_obj(coalesce(v.map,'{}'::jsonb) ORDER BY seq ) map
    FROM 	
        --re-aggregate return values and explude any records where one or more regex failed with a null result
        agg_rx u
        LEFT OUTER JOIN tps.map_rv v ON
            v.target = u.target AND
            v.srce = u.srce AND
            v.retval <@ u.retval
    GROUP BY
        u.srce,
        u.id,
        u.rec
)


UPDATE
    tps.trans t
SET
    map = o.map,
    parse = o.retain
FROM
    agg_orig o
WHERE
    o.id = t.id