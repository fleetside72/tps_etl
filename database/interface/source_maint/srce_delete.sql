DROP FUNCTION IF EXISTS tps.srce_delete(jsonb);
CREATE FUNCTION tps.srce_delete(_defn jsonb) RETURNS jsonb
AS
$f$
DECLARE 
    _message jsonb;
    _MESSAGE_TEXT text;
    _PG_EXCEPTION_DETAIL text;
    _PG_EXCEPTION_HINT text;
    _rebuild BOOLEAN;
BEGIN

    -------------------------------do delete---------------------------------

    DELETE FROM tps.srce WHERE srce = _defn->>'name';
    --could move this record to a "recycle bin" table for a certain period of time
    --need to handle cascading record deletes
    
    ---------------------------set message-----------------------------------
    _message:= 
    (
        $$
            {
            "status":"complete",
            "message":"source was moved to the recycle bin which has not been implemented so...hope you're in dev"
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
                "message":"error dropping the source"
            }
        $$::jsonb)
        ||jsonb_build_object('message_text',_MESSAGE_TEXT)
        ||jsonb_build_object('pg_exception_detail',_PG_EXCEPTION_DETAIL);
    RETURN _message;
END;
$f$
LANGUAGE plpgsql