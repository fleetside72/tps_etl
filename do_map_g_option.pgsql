
WITH

--------------------apply regex operations to transactions-----------------------------------------------------------------------------------

rx AS (
SELECT 
    t.srce,
    t.id,
    t.rec,
    m.target,
    regex->>'map' map_intention,
    regex->>'function' regex_function,
    e.v ->> 'field' result_key_name,
    e.v ->> 'key' target_json_path,
    e.v ->> 'flag' regex_options_flag,
    e.v->>'retain' retain_result,
    e.v->>'regex' regex_expression,
    e.rn target_item_number,
    COALESCE(mt.rn,rp.rn,1) result_number,
    mt.mt rx_match,
    rp.rp rx_replace,
    CASE regex->>'map'
        WHEN 'yes' THEN
            e.v->>'field'
        ELSE
            null
    END map_key,
    CASE regex->>'map'
        WHEN 'yes' THEN
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
        ELSE
            NULL
    END map_val,
    CASE e.v->>'retain'
        WHEN 'y' THEN
            e.v->>'field'
        ELSE
            NULL
    END retain_key,
    CASE e.v->>'retain'
        WHEN 'y' THEN
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
        ELSE
            NULL
    END retain_val
FROM 
    tps.map_rm m
    LEFT JOIN LATERAL jsonb_array_elements(m.regex->'where') w(v) ON TRUE
    INNER JOIN tps.trans t ON 
        t.srce = m.srce AND
        t.rec @> w.v
    LEFT JOIN LATERAL jsonb_array_elements(m.regex->'defn') WITH ORDINALITY e(v, rn) ON true
    LEFT JOIN LATERAL regexp_matches(t.rec #>> ((e.v ->> 'key')::text[]), e.v ->> 'regex'::text,COALESCE(e.v ->> 'flag','')) WITH ORDINALITY mt(mt, rn) ON
        m.regex->>'function' = 'extract'
    LEFT JOIN LATERAL regexp_replace(t.rec #>> ((e.v ->> 'key')::text[]), e.v ->> 'regex'::text, e.v ->> 'replace'::text,e.v ->> 'flag') WITH ORDINALITY rp(rp, rn) ON
        m.regex->>'function' = 'replace'
WHERE
    t.srce = 'PNCC'
ORDER BY 
    t.id DESC,
    m.target,
    e.rn,
    COALESCE(mt.rn,rp.rn,1)
)

, agg_to_target_items AS (
SELECT 
    srce
    ,id
    ,target
    ,map_intention
    ,regex_function
    ,target_item_number
    ,result_key_name
    ,target_json_path
    ,CASE WHEN map_key IS NULL 
        THEN    
            NULL 
        ELSE 
            jsonb_build_object(
                map_key,
                CASE WHEN max(result_number) = 1
                    THEN
                        jsonb_agg(map_val ORDER BY result_number) -> 0
                    ELSE
                        jsonb_agg(map_val ORDER BY result_number)
                END
            ) 
    END map_val
    ,CASE WHEN retain_key IS NULL 
        THEN 
            NULL 
        ELSE 
            jsonb_build_object(
                retain_key,
                CASE WHEN max(result_number) = 1
                    THEN
                        jsonb_agg(retain_val ORDER BY result_number) -> 0
                    ELSE
                        jsonb_agg(retain_val ORDER BY result_number)
                END
            ) 
    END retain_val
FROM 
    rx
GROUP BY
    srce
    ,id
    ,target
    ,map_intention
    ,regex_function
    ,target_item_number
    ,result_key_name
    ,target_json_path
    ,map_key
    ,retain_key
)

, agg_to_target AS (
SELECT
    srce
    ,id
    ,target
    ,map_intention
    ,tps.jsonb_concat_obj(map_val) map_val
    ,tps.jsonb_concat_obj(retain_val) retain_val
FROM
    agg_to_target_items
GROUP BY
    srce
    ,id
    ,target
    ,map_intention
ORDER BY
    id
)

, link_map AS (
SELECT
    a.srce
    ,a.id
    ,a.target
    ,a.map_intention
    ,a.map_val
    ,jsonb_strip_nulls(a.retain_val) retain_value
    ,v.map
FROM
    agg_to_target a
    LEFT OUTER JOIN tps.map_rv v ON
        v.srce = a.srce AND
        v.target = a.target AND
        v.retval = a.map_val
)

SELECT
    srce
    ,id
    ,tps.jsonb_concat_obj(COALESCE(retain_value,'{}'::jsonb)) retain_val
    ,tps.jsonb_concat_obj(COALESCE(map,'{}'::jsonb)) map
FROM
    link_map
GROUP BY
    srce
    ,id
    