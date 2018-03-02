CREATE OR REPLACE FUNCTION tps.srce_map_val_set(_srce text, _target text, _ret jsonb, _map jsonb) RETURNS jsonb
AS
$f$

DECLARE
    _message jsonb;
    _MESSAGE_TEXT text;
    _PG_EXCEPTION_DETAIL text;
    _PG_EXCEPTION_HINT text;

BEGIN

    INSERT INTO
        tps.map_rv
    SELECT
        _srce
        ,_target
        ,_ret
        ,_map
    ON CONFLICT ON CONSTRAINT map_rv_pk DO UPDATE SET
        srce = _srce
        ,target = _target
        ,retval = _ret
        ,map = _map;

    _message:= jsonb_build_object('status','complete');
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
                "message":"error setting map value"
            }
        $$::jsonb)
        ||jsonb_build_object('message_text',_MESSAGE_TEXT)
        ||jsonb_build_object('pg_exception_detail',_PG_EXCEPTION_DETAIL);

        RETURN _message;

END
$f$
language plpgsql