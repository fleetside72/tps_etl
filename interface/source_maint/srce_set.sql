DROP FUNCTION IF EXISTS tps.srce_set(jsonb);
CREATE FUNCTION tps.srce_set(_defn jsonb) RETURNS jsonb
AS
$f$
DECLARE 
    _message jsonb;
    _MESSAGE_TEXT text;
    _PG_EXCEPTION_DETAIL text;
    _PG_EXCEPTION_HINT text;
BEGIN
    INSERT INTO
        tps.srce (srce, defn, hist)
    SELECT
        --extract name from defintion
        _defn->>'name'
        --add current timestamp to defintions
        ,_defn
        --add definition
        ,jsonb_build_object(
                'hist_defn',_defn
                ,'effective',jsonb_build_array(CURRENT_TIMESTAMP,null::timestamptz)
        ) || '[]'::jsonb
    ON CONFLICT ON CONSTRAINT srce_pkey DO UPDATE
        SET
            defn = _defn
            ,hist = 
                    --the new definition going to position -0-
                    jsonb_build_object(
                        'hist_defn',_defn
                        ,'effective',jsonb_build_array(CURRENT_TIMESTAMP,null::timestamptz)
                    ) 
                    --the previous definition, set upper bound of effective range which was previously null
                    || jsonb_set(
                        srce.hist
                        ,'{0,effective,1}'::text[]
                        ,to_jsonb(CURRENT_TIMESTAMP)
                    );
    
    _message:= 
        (
            $$
                {
                "status":"complete",
                "message":"source set"
                }
            $$::jsonb
        );
    RETURN _message;

    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS 
            _MESSAGE_TEXT = MESSAGE_TEXT,
            _PG_EXCEPTION_DETAIL = PG_EXCEPTION_DETAIL,
            _PG_EXCEPTION_HINT = PG_EXCEPTION_HINT;
        _message:= 
        ($$
            {
                "status":"fail",
                "message":"error importing data"
            }
        $$::jsonb)
        ||jsonb_build_object('message_text',_MESSAGE_TEXT)
        ||jsonb_build_object('pg_exception_detail',_PG_EXCEPTION_DETAIL);
    RETURN _message;
END;
$f$
LANGUAGE plpgsql