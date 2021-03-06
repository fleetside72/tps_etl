DROP FUNCTION IF EXISTS tps.test_regex_rec(jsonb);
CREATE FUNCTION tps.test_regex_recs(_defn jsonb) RETURNS jsonb
LANGUAGE plpgsql
AS
$f$
DECLARE
    _rslt jsonb;
BEGIN

WITH

--------------------apply regex operations to transactions---------------------------------------------------------------------------------

rx AS (
        SELECT 
            t.srce,
            t.id,
            t.rec,
            m.target,
            m.seq,
            regex->'regex'->>'function' regex_function,
            e.v ->> 'field' result_key_name,
            e.v ->> 'key' target_json_path,
            e.v ->> 'flag' regex_options_flag,
            e.v->>'map' map_intention,
            e.v->>'retain' retain_result,
            e.v->>'regex' regex_expression,
            e.rn target_item_number,
            COALESCE(mt.rn,rp.rn,1) result_number,
            mt.mt rx_match,
            rp.rp rx_replace,
            CASE e.v->>'map'
                WHEN 'y' THEN
                    e.v->>'field'
                ELSE
                    null
            END map_key,
            CASE e.v->>'map'
                WHEN 'y' THEN
                    CASE regex->'regex'->>'function'
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
                    CASE regex->'regex'->>'function'
                        WHEN 'extract' THEN
                            CASE WHEN array_upper(mt.mt,1)=1 
                                THEN to_json(trim(mt.mt[1]))
                                ELSE array_to_json(mt.mt)
                            END::jsonb
                        WHEN 'replace' THEN
                            to_jsonb(rtrim(rp.rp))
                        ELSE
                            '{}'::jsonb
                    END
                ELSE
                    NULL
            END retain_val
        FROM 
            --------------------------start with all regex maps------------------------------------------------------------------------------------
            (SELECT _defn->>'srce' srce, _defn->>'name' target, _defn regex, (_defn->>'sequence')::numeric seq) m
            --------------------------isolate matching basis to limit map to only look at certain json---------------------------------------------
            LEFT JOIN LATERAL jsonb_array_elements(m.regex->'regex'->'where') w(v) ON TRUE
            --------------------------break out array of regluar expressions in the map------------------------------------------------------------
            LEFT JOIN LATERAL jsonb_array_elements(m.regex->'regex'->'defn') WITH ORDINALITY e(v, rn) ON true
            --------------------------join to main transaction table but only certain key/values are included--------------------------------------
            INNER JOIN tps.trans t ON 
                t.srce = m.srce AND
                t.rec @> w.v
            --------------------------each regex references a path to the target value, extract the target from the reference and do regex---------
            LEFT JOIN LATERAL regexp_matches(t.rec #>> ((e.v ->> 'key')::text[]), e.v ->> 'regex'::text,COALESCE(e.v ->> 'flag','')) WITH ORDINALITY mt(mt, rn) ON
                m.regex->'regex'->>'function' = 'extract'
            --------------------------same as above but for a replacement type function------------------------------------------------------------
            LEFT JOIN LATERAL regexp_replace(t.rec #>> ((e.v ->> 'key')::text[]), e.v ->> 'regex'::text, e.v ->> 'replace'::text,e.v ->> 'flag') WITH ORDINALITY rp(rp, rn) ON
                m.regex->'regex'->>'function' = 'replace'
        ORDER BY 
            t.id DESC,
            m.target,
            e.rn,
            COALESCE(mt.rn,rp.rn,1)
)

--SELECT * FROM rx LIMIT 100


, agg_to_target_items AS (
SELECT 
    srce
    ,id
    ,rec
    ,target
    ,seq
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
    ,rec
    ,target
    ,seq
    ,map_intention
    ,regex_function
    ,target_item_number
    ,result_key_name
    ,target_json_path
    ,map_key
    ,retain_key
)

--SELECT * FROM agg_to_target_items LIMIT 100


, agg_to_target AS (
SELECT
    srce
    ,id
    ,rec
    ,target
    ,seq
    ,map_intention
    ,tps.jsonb_concat_obj(COALESCE(map_val,'{}'::JSONB)) map_val
    ,jsonb_strip_nulls(tps.jsonb_concat_obj(COALESCE(retain_val,'{}'::JSONB))) retain_val
FROM
    agg_to_target_items
GROUP BY
    srce
    ,id
    ,rec
    ,target
    ,seq
    ,map_intention
)
, agg_to_ret AS (
SELECT
	srce
	,target
	,seq
	,map_intention
	,map_val
	,retain_val
	,count(*) "count"
    ,jsonb_agg(rec) rec
FROM 
	agg_to_target
GROUP BY
	srce
	,target
	,seq
	,map_intention
	,map_val
	,retain_val
)
SELECT
    jsonb_agg(row_to_json(agg_to_ret)::jsonb)
INTO
    _rslt
FROM
    agg_to_ret;
RETURN _rslt;
END;
$f$;