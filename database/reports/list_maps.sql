SELECT 
    m.srce,
    m.target,
    regex->>'function' regex_function,
    regex->>'where' where_clause,
    e.v ->> 'field' result_key_name,
    e.v ->> 'key' target_json_path,
    e.v ->> 'flag' regex_options_flag,
    e.v->>'map' map_intention,
    e.v->>'retain' retain_result,
    e.v->>'regex' regex_expression,
    e.rn target_item_number
FROM 
    tps.map_rm m
    LEFT JOIN LATERAL jsonb_array_elements(m.regex->'defn') WITH ORDINALITY e(v, rn) ON true
ORDER BY 
    m.srce,
    m.target,
    e.rn