DROP FUNCTION tps.report_unmapped;
CREATE FUNCTION tps.report_unmapped(_srce text) RETURNS TABLE 
(
    source text, 
    map text,
    ret_val jsonb,
    "count" bigint
)
LANGUAGE plpgsql
AS
$f$
BEGIN

/*
first get distinct target json values
then apply regex
*/

RETURN QUERY
WITH

--------------------apply regex operations to transactions---------------------------------------------------------------------------------

rx AS (
SELECT 
    t.srce,
    t.id,
    t.rec,
    m.target,
    m.seq,
    regex->>'function' regex_function,
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
    --------------------------json key name assigned to return value-----------------------------------------------------------------------
    CASE e.v->>'map'
        WHEN 'y' THEN
            e.v->>'field'
        ELSE
            null
    END map_key,
    --------------------------json value resulting from regular expression-----------------------------------------------------------------
    CASE e.v->>'map'
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
    END map_val,
    --------------------------flag for if retruned regex result is stored as a new part of the final json output---------------------------
    CASE e.v->>'retain'
        WHEN 'y' THEN
            e.v->>'field'
        ELSE
            NULL
    END retain_key,
    --------------------------push regex result into json object---------------------------------------------------------------------------
    CASE e.v->>'retain'
        WHEN 'y' THEN
            CASE regex->>'function'
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
    tps.map_rm m
    --------------------------isolate matching basis to limit map to only look at certain json---------------------------------------------
    JOIN LATERAL jsonb_array_elements(m.regex->'where') w(v) ON TRUE
    --------------------------break out array of regluar expressions in the map------------------------------------------------------------
    JOIN LATERAL jsonb_array_elements(m.regex->'defn') WITH ORDINALITY e(v, rn) ON true
    --------------------------join to main transaction table but only certain key/values are included--------------------------------------
    INNER JOIN tps.trans t ON 
        t.srce = m.srce AND
        t.rec @> w.v
    --------------------------each regex references a path to the target value, extract the target from the reference and do regex---------
    LEFT JOIN LATERAL regexp_matches(t.rec #>> ((e.v ->> 'key')::text[]), e.v ->> 'regex'::text,COALESCE(e.v ->> 'flag','')) WITH ORDINALITY mt(mt, rn) ON
        m.regex->>'function' = 'extract'
    --------------------------same as above but for a replacement type function------------------------------------------------------------
    LEFT JOIN LATERAL regexp_replace(t.rec #>> ((e.v ->> 'key')::text[]), e.v ->> 'regex'::text, e.v ->> 'replace'::text,e.v ->> 'flag') WITH ORDINALITY rp(rp, rn) ON
        m.regex->>'function' = 'replace'
WHERE
    --t.allj IS NULL
    t.srce = _srce AND
    e.v @> '{"map":"y"}'::jsonb
    --rec @> '{"Transaction":"ACH Credits","Transaction":"ACH Debits"}'
    --rec @> '{"Description":"CHECK 93013270 086129935"}'::jsonb
/*
ORDER BY 
    t.id DESC,
    m.target,
    e.rn,
    COALESCE(mt.rn,rp.rn,1)
*/
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
    ,jsonb_agg(reC) recs
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

, link_map AS (
SELECT
    a.srce
    ,a.target
    ,a.seq
    ,a.map_intention
    ,a.map_val
    ,a."count"
    ,a.recs
    ,a.retain_val
    ,v.map mapped_val
FROM
    agg_to_ret a
    LEFT OUTER JOIN tps.map_rv v ON
        v.srce = a.srce AND
        v.target = a.target AND
        v.retval = a.map_val
)
SELECT
    l.srce
    ,l.target
    ,l.map_val
    ,l."count"
    ,l.recs
FROM
    link_map l
WHERE
    l.mapped_val IS NULL
ORDER BY
    l.srce
    ,l.target
    ,l."count" desc;
END;
$f$