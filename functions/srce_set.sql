
CREATE OR REPLACE FUNCTION tps.srce_set(_name text, _defn jsonb) RETURNS jsonb
AS $f$

DECLARE
_cnt int;
_conflict BOOLEAN;
_message jsonb;
_sql text;

BEGIN

/*
1. determine if insert or update
2. if update, determine if conflicts exists
3. do merge
*/

    -------check for transctions already existing under this source-----------
    SELECT
        COUNT(*)
    INTO
        _cnt
    FROM
        tps.trans
    WHERE
        srce = _name;

    -------set a message------------------------------------------------------
    IF _cnt > 0 THEN
        _conflict = TRUE;
        --get out of the function somehow
        _message = 
        $$
                {
                    "message":"transactions already exist under source profile, cannot change the definition"
                    ,"status":"error"
                }
        $$::jsonb;
        return _message;
    END IF;

    /*-------------------------------------------------------
    schema validation
    ---------------------------------------------------------*/
    
    -------------------insert definition----------------------------------------
    INSERT INTO
        tps.srce
    SELECT
        _name, _defn
    ON CONFLICT ON CONSTRAINT srce_pkey DO UPDATE
        SET
            defn = _defn;

    ------------------drop existing type-----------------------------------------

    EXECUTE format('DROP TYPE IF EXISTS tps.%I',_name);

    ------------------create new type--------------------------------------------

    SELECT
        string_agg(quote_ident(prs.key)||' '||prs.type,',')
    INTO
        _sql
    FROM 
        tps.srce
        --unwrap the schema definition array
        LEFT JOIN LATERAL jsonb_populate_recordset(null::tps.srce_defn_schema, defn->'schema') prs ON TRUE
    WHERE   
        srce = _name
    GROUP BY
        srce;

    RAISE NOTICE 'CREATE TYPE tps.% AS (%)',_name,_sql;

    EXECUTE format('CREATE TYPE tps.%I AS (%s)',_name,_sql);

    ----------------set message-----------------------------------------------------
    
    _message = 
        $$
                {
                    "message":"definition set"
                    ,"status":"success"
                }
        $$::jsonb;
    return _message;

END;
$f$
LANGUAGE plpgsql
