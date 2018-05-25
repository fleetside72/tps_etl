DROP FUNCTION IF EXISTS tps.map_rv_set;
CREATE OR REPLACE FUNCTION tps.map_rv_set(_defn jsonb) RETURNS jsonb
AS
$f$
DECLARE
    _message jsonb;
    _MESSAGE_TEXT text;
    _PG_EXCEPTION_DETAIL text;
    _PG_EXCEPTION_HINT text;
BEGIN
    INSERT INTO
        tps.map_rv (srce, target, retval, map, hist)
    SELECT 
        r.source
        ,r.map
        ,r.ret_val
        ,r.mapped
        ,jsonb_build_object(
                'hist_defn',mapped
                ,'effective',jsonb_build_array(CURRENT_TIMESTAMP,null::timestamptz)
            ) || '[]'::jsonb
    FROM
        JSONB_ARRAY_ELEMENTS(_defn) WITH ORDINALITY ae(r,s)
        JOIN LATERAL jsonb_to_record(ae.r) r(source TEXT,map TEXT, ret_val jsonb, mapped jsonb) ON TRUE
    ON CONFLICT ON CONSTRAINT map_rv_pk DO UPDATE
        SET
            map = excluded.map
            ,hist = 
                --the new definition going to position -0-
                jsonb_build_object(
                    'hist_defn',excluded.map
                    ,'effective',jsonb_build_array(CURRENT_TIMESTAMP,null::timestamptz)
                ) 
                --the previous definition, set upper bound of effective range which was previously null
                || jsonb_set(
                    map_rv.hist
                    ,'{0,effective,1}'::text[]
                    ,to_jsonb(CURRENT_TIMESTAMP)
                );

    -------return message--------------------------------------------------------------------------------------------------
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
END;
$f$
LANGUAGE plpgsql;