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

    ---------test if anythign is changing--------------------------------------------------------------------------------------------

    IF _defn = (SELECT defn FROM tps.srce WHERE srce = _defn->>'name') THEN
         _message:= 
        (
            $$
                {
                "status":"complete",
                "message":"source was not different no action taken"
                }
            $$::jsonb
        );
        RETURN _message;
    END IF;

    ---------if the constraint definition is changing, rebuild for existing records---------------------------------------------------

    SELECT 
        NOT (_defn->'constraint' = (SELECT defn->'constraint' FROM tps.srce WHERE srce = _defn->>'name'))
    INTO
        _rebuild;

    RAISE NOTICE '%',_rebuild::text;

    ---------do merge-----------------------------------------------------------------------------------------------------------------

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
    --rebuild constraint key if necessary---------------------------------------------------------------------------------------

    IF _rebuild THEN
        WITH
        rebuild AS (
            SELECT
                j.srce
                ,j.rec
                ,j.id
                --aggregate back to the record since multiple paths may be listed in the constraint
                ,tps.jsonb_concat_obj(
                    jsonb_build_object(
                        --the new json key is the path itself
                        cons.path->>0
                        ,j.rec#>((cons.path->>0)::text[])
                    ) 
                ) json_key
            FROM
                tps.trans j
                INNER JOIN tps.srce s ON
                    s.srce = j.srce
                JOIN LATERAL jsonb_array_elements(s.defn->'constraint') WITH ORDINALITY cons(path, seq)  ON TRUE
            WHERE
                s.srce = _defn->>'name'
            GROUP BY
                j.rec
                ,j.id
        )
        UPDATE
            tps.trans t
        SET
            ic = r.json_key
        FROM
            rebuild r
        WHERE
            t.id = r.id;
         _message:= 
        (
            $$
                {
                "status":"complete",
                "message":"source set and constraint rebuilt on existing records"
                }
            $$::jsonb
        );
    ELSE
        _message:= 
        (
            $$
                {
                "status":"complete",
                "message":"source set"
                }
            $$::jsonb
        );
    END IF;

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