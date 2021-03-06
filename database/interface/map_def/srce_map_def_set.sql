CREATE OR REPLACE FUNCTION tps.srce_map_def_set(_defn jsonb) RETURNS jsonb
AS
$f$

DECLARE
    _message jsonb;
    _MESSAGE_TEXT text;
    _PG_EXCEPTION_DETAIL text;
    _PG_EXCEPTION_HINT text;

BEGIN

    WITH 
    ------------------------------------------stage rows to insert-----------------------------------------------------
    stg AS (
        SELECT
            --data source
            ae.r->>'srce' srce
            --map name
            ,ae.r->>'name' target
            --map definition
            ,ae.r regex
            --map aggregation sequence
            ,(ae.r->>'sequence')::INTEGER seq
            --history definition
            ,jsonb_build_object(
                'hist_defn',ae.r
                ,'effective',jsonb_build_array(CURRENT_TIMESTAMP,null::timestamptz)
            ) || '[]'::jsonb hist
            --determine if the rows are new or match
            ,(m.regex->>'regex' = ae.r->>'regex')::BOOLEAN rebuild
        FROM
            jsonb_array_elements(_defn) ae(r)
            LEFT OUTER JOIN tps.map_rm m ON
                m.srce = ae.r->>'srce'
                AND m.target = ae.t->>'name'
    )
    ---------------------------------------do the upsert-------------------------------------------------------------------
    ,ins AS (
        INSERT INTO
            tps.map_rm (srce, target, regex, seq, hist)
        SELECT
            srce
            ,target
            ,regex
            ,seq
            ,hist
        FROM
            stg
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
                    )
    )
    ---------------------------get list of sources that had maps change--------------------------------------------------------
    , to_update AS (
    SELECT DISTINCT
        srce
    FROM
        ins
    WHERE
        rebuild = TRUE
    )
    --------------------------call the map overwrite for each source and return all the messages into message----------------
    /*the whole source must be overwritten because if an element is no longer returned it shoudl be wiped from the data*/
    SELECT
        jsonb_agg(x.message)
    INTO
        _message
    FROM
        to_update
        JOIN LATERAL tps.srce_map_overwrite(to_update.srce) AS x(message) ON TRUE;

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