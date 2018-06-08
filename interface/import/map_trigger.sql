CREATE OR REPLACE FUNCTION tps.trans_insert_map() RETURNS TRIGGER 
AS 
$f$
    DECLARE
        _cnt INTEGER;

    BEGIN
        IF (TG_OP = 'INSERT') THEN


            WITH
            --------------------apply regex operations to transactions-----------------------------------------------------------------------------------

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
                    tps.map_rm m
                    LEFT JOIN LATERAL jsonb_array_elements(m.regex->'regex'->'where') w(v) ON TRUE
                    INNER JOIN new_table t ON 
                        t.srce = m.srce AND
                        t.rec @> w.v
                    LEFT JOIN LATERAL jsonb_array_elements(m.regex->'regex'->'defn') WITH ORDINALITY e(v, rn) ON true
                    LEFT JOIN LATERAL regexp_matches(t.rec #>> ((e.v ->> 'key')::text[]), e.v ->> 'regex'::text,COALESCE(e.v ->> 'flag','')) WITH ORDINALITY mt(mt, rn) ON
                        m.regex->'regex'->>'function' = 'extract'
                    LEFT JOIN LATERAL regexp_replace(t.rec #>> ((e.v ->> 'key')::text[]), e.v ->> 'regex'::text, e.v ->> 'replace'::text,e.v ->> 'flag') WITH ORDINALITY rp(rp, rn) ON
                        m.regex->'regex'->>'function' = 'replace'
                ORDER BY 
                    t.id DESC,
                    m.target,
                    e.rn,
                    COALESCE(mt.rn,rp.rn,1)
            )

            --SELECT count(*) FROM rx LIMIT 100


            , agg_to_target_items AS (
            SELECT 
                srce
                ,id
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
                ,target
                ,seq
                ,map_intention
            ORDER BY
                id
            )


            --SELECT * FROM agg_to_target


            , link_map AS (
            SELECT
                a.srce
                ,a.id
                ,a.target
                ,a.seq
                ,a.map_intention
                ,a.map_val
                ,a.retain_val retain_value
                ,v.map
            FROM
                agg_to_target a
                LEFT OUTER JOIN tps.map_rv v ON
                    v.srce = a.srce AND
                    v.target = a.target AND
                    v.retval = a.map_val
            )

            --SELECT * FROM link_map

            , agg_to_id AS (
            SELECT
                srce
                ,id
                ,tps.jsonb_concat_obj(COALESCE(retain_value,'{}'::jsonb) ORDER BY seq DESC) retain_val
                ,tps.jsonb_concat_obj(COALESCE(map,'{}'::jsonb)) map
            FROM
                link_map
            GROUP BY
                srce
                ,id
            )

            --SELECT agg_to_id.srce, agg_to_id.id, jsonb_pretty(agg_to_id.retain_val) , jsonb_pretty(agg_to_id.map) FROM agg_to_id ORDER BY id desc LIMIT 100
            
            --create a complete list of all new inserts assuming some do not have maps (left join)
            ,join_all AS (
                SELECT
                    n.srce
                    ,n.id
                    ,n.rec
                    ,a.retain_val parse
                    ,a.map
                    ,n.rec||COALESCE(a.map||a.retain_val,'{}'::jsonb) allj
                FROM
                    new_table n
                    LEFT OUTER JOIN agg_to_id a ON
                        a.id = n.id
            )

            --update trans with join_all recs
            UPDATE
                tps.trans t
            SET
                parse = a.parse
                ,map = a.map
                ,allj = a.allj
            FROM
               join_all a
            WHERE
                t.id = a.id;
                

        END IF;
        RETURN NULL;
    END;
$f$ LANGUAGE plpgsql;

CREATE TRIGGER trans_insert
    AFTER INSERT ON tps.trans
    REFERENCING NEW TABLE AS new_table
    FOR EACH STATEMENT EXECUTE PROCEDURE tps.trans_insert_map();