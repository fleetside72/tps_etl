/*
This function takes and array of definition object where "name" object is the primary key
It will force the entire body of sources to match what is received
*/
DROP FUNCTION IF EXISTS tps.srce_overwrite_all(jsonb);
CREATE FUNCTION tps.srce_overwrite_all(_defn jsonb) RETURNS jsonb
AS
$f$
DECLARE 
    _message jsonb;
    _MESSAGE_TEXT text;
    _PG_EXCEPTION_DETAIL text;
    _PG_EXCEPTION_HINT text;
    _rebuild BOOLEAN;
BEGIN

    WITH
    --retain the results of the update by srce
    _set AS (
    SELECT
        j.rn rn
        ,j.e->>'name' srce
        ,j.e defn
    FROM
        jsonb_array_elements(_defn) WITH ORDINALITY j(e, rn)
    )
    --full join
    ,_full AS (
        SELECT
            COALESCE(_srce.srce,_set.srce) srce
            ,CASE COALESCE(_set.srce,'DELETE') WHEN 'DELETE' THEN 'DELETE' ELSE 'SET' END actn
            ,COALESCE(_set.defn,_srce.defn) defn
        FROM
            tps.srce _srce
            FULL OUTER JOIN _set ON
                _set.srce = _srce.srce
    )
    --call functions from list
    ,_do AS (
    SELECT 
        f.srce
        ,f.actn
        ,COALESCE(setd.message, deld.message) message
    FROM 
        _full f
        LEFT JOIN LATERAL tps.srce_set(defn) setd(message) ON f.actn = 'SET'
        LEFT JOIN LATERAL tps.srce_delete(defn) deld(message) ON f.actn = 'DELETE'
    )
    --aggregate all the messages into one message
    ----
    ----    should look at rolling back the whole thing if one of the function returns a fail. stored proc could do this.
    ----
    SELECT
        jsonb_agg(jsonb_build_object('source',srce,'status',message->>'status','message',message->>'message'))
    INTO
        _message
    FROM
        _do;

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
                "message":"error updating sources"
            }
        $$::jsonb)
        ||jsonb_build_object('message_text',_MESSAGE_TEXT)
        ||jsonb_build_object('pg_exception_detail',_PG_EXCEPTION_DETAIL);
    RETURN _message;
END;
$f$
LANGUAGE plpgsql