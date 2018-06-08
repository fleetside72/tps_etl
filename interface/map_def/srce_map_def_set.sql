CREATE OR REPLACE FUNCTION tps.srce_map_def_set(_defn jsonb) RETURNS jsonb
AS
$f$

DECLARE
    _message jsonb;
    _MESSAGE_TEXT text;
    _PG_EXCEPTION_DETAIL text;
    _PG_EXCEPTION_HINT text;

BEGIN


    INSERT INTO
        tps.map_rm (srce, target, regex, seq, hist)
    SELECT
        --data source
        ae.r->>'srce'
        --map name
        ,ae.r->>'name'
        --map definition
        ,ae.r
        --map aggregation sequence
        ,(ae.r->>'sequence')::INTEGER
        --history definition
        ,jsonb_build_object(
            'hist_defn',ae.r
            ,'effective',jsonb_build_array(CURRENT_TIMESTAMP,null::timestamptz)
        ) || '[]'::jsonb
    FROM
        jsonb_array_elements(_defn) ae(r)
    ON CONFLICT ON CONSTRAINT map_rm_pk DO UPDATE SET
        srce = excluded.srce
        ,target = excluded.target
        ,regex = excluded.regex
        ,seq = excluded.seq
        ,hist = 
                --the new definition going to position -0-
                jsonb_build_object(
                    'hist_defn',excluded.regex
                    ,'effective',jsonb_build_array(CURRENT_TIMESTAMP,null::timestamptz)
                ) 
                --the previous definition, set upper bound of effective range which was previously null
                || jsonb_set(
                    map_rm.hist
                    ,'{0,effective,1}'::text[]
                    ,to_jsonb(CURRENT_TIMESTAMP)
                );

     _message:= jsonb_build_object('status','complete','message','definition has been set');
    return _message;


    GET STACKED DIAGNOSTICS 
            _MESSAGE_TEXT = MESSAGE_TEXT,
            _PG_EXCEPTION_DETAIL = PG_EXCEPTION_DETAIL,
            _PG_EXCEPTION_HINT = PG_EXCEPTION_HINT;
        _message:= 
        ($$
            {
                "status":"fail",
                "message":"error setting definition"
            }
        $$::jsonb)
        ||jsonb_build_object('message_text',_MESSAGE_TEXT)
        ||jsonb_build_object('pg_exception_detail',_PG_EXCEPTION_DETAIL);
        return _message;



END;
$f$
language plpgsql