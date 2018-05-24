CREATE OR REPLACE FUNCTION tps.srce_map_def_set(_defn jsonb) RETURNS jsonb
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
            _defn->>'srce'
            ,_defn->>'name'
            ,_defn
            ,_defn->>'sequence'
        ON CONFLICT ON CONSTRAINT map_rm_pk DO UPDATE SET
            srce = _defn->>'srce'
            ,target = _defn->>'name'
            ,regex = _defn
            ,seq = _defn->>'sequence';

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