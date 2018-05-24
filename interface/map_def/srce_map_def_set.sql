CREATE OR REPLACE FUNCTION tps.srce_map_def_set(_srce text, _map text, _defn jsonb, _seq int) RETURNS jsonb
AS
$f$

DECLARE
    _message jsonb;
    _MESSAGE_TEXT text;
    _PG_EXCEPTION_DETAIL text;
    _PG_EXCEPTION_HINT text;

BEGIN

    BEGIN

        INSERT INTO
            tps.map_rm
        SELECT
            _srce
            ,_map
            ,_defn
            ,_seq
        ON CONFLICT ON CONSTRAINT map_rm_pk DO UPDATE SET
            srce = _srce
            ,target = _map
            ,regex = _defn
            ,seq = _seq;

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

    _message:= jsonb_build_object('status','complete','message','definition has been set');
    return _message;

END;
$f$
language plpgsql