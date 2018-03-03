
CREATE OR REPLACE FUNCTION tps.srce_set(_name text, _defn jsonb) RETURNS jsonb
AS $f$

DECLARE
_cnt int;
_conflict BOOLEAN;
_message jsonb;
_sql text;
_cur_sch jsonb;

BEGIN

/*
1. determine if insert or update
2. if update, determine if conflicts exists
3. do merge
*/

    -------extract current source schema for compare--------------------------
    SELECT
        defn->'schema'
    INTO
        _cur_sch
    FROM
        tps.srce
    WHERE
        srce = _name;

    -------check for transctions already existing under this source-----------
    SELECT
        COUNT(*)
    INTO
        _cnt
    FROM
        tps.trans
    WHERE
        srce = _name;

    --if there are transaction already and the schema is different stop--------
    IF _cnt > 0 THEN
        IF _cur_sch <> _defn->'schema' THEN
            _conflict = TRUE;
            --get out of the function somehow
            _message = 
            $$
                    {
                        "message":"transactions already exist under source profile and there is a pending schema change"
                        ,"status":"error"
                    }
            $$::jsonb;
            return _message;
        END IF;
    END IF;

    /*-------------------------------------------------------
    do schema validation fo _defn object?
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

    EXECUTE format('COMMENT ON TYPE tps.%I IS %L',_name,(_defn->>'description'));

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
