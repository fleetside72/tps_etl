/*
This function takes and array of definition object where "name" object is the primary key
It will force the entire body of sources to match what is received
*/
DROP FUNCTION IF EXISTS tps.srce_set(jsonb);
CREATE FUNCTION tps.srce_set(_defn jsonb) RETURNS jsonb
AS
$f$
DECLARE 
    _message jsonb;
    _MESSAGE_TEXT text;
    _PG_EXCEPTION_DETAIL text;
    _PG_EXCEPTION_HINT text;
    _rebuild BOOLEAN;
BEGIN

    --do a lateral join and expand the array
    --do another lateral join calling the single set function for each row and aggregating the result messages

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