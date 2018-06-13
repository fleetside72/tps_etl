CREATE OR REPLACE FUNCTION tps.srce_map_def_set_single(_defn jsonb, _rebuild BOOLEAN) RETURNS jsonb
AS
$f$

DECLARE
    _message jsonb;
    _MESSAGE_TEXT text;
    _PG_EXCEPTION_DETAIL text;
    _PG_EXCEPTION_HINT text;

BEGIN

    ---------test if anythign is changing--------------------------------------------------------------------------------------------

    IF _defn->'regex' = (SELECT regex->'regex' FROM tps.map_rm WHERE srce = _defn->>'srce' and target = _defn->>'name') THEN
         _message:= 
        (
            $$
                {
                "status":"complete",
                "message":"map was not different no action taken"
                }
            $$::jsonb
        );
        RETURN _message;
    END IF;

    ---------do the rebuild-----------------------------------------------------------------------------------------------------------

    INSERT INTO
        tps.map_rm (srce, target, regex, seq, hist)
    SELECT
        --data source
        _defn->>'srce'
        --map name
        ,_defn->>'name'
        --map definition
        ,_defn
        --map aggregation sequence
        ,(_defn->>'sequence')::INTEGER
        --history definition
        ,jsonb_build_object(
            'hist_defn',_defn
            ,'effective',jsonb_build_array(CURRENT_TIMESTAMP,null::timestamptz)
        ) || '[]'::jsonb
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

    --------------if rebuild was flag call the rebuild--------------------------------------------------------------------------------

    IF _rebuild THEN
        SELECT
            x.message||'{"step":"overwrite maps in tps.trans"}'::jsonb
        INTO
            _message
        FROM
            tps.srce_map_overwrite(_defn->>'srce') as X(message);
    END IF;

    return _message;

    EXCEPTION WHEN OTHERS THEN
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