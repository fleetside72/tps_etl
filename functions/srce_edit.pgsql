
CREATE OR REPLACE FUNCTION tps.srce_set(_name text, _defn jsonb) RETURNS jsonb
AS $f$

DECLARE
_cnt int;
_conflict BOOLEAN;
_message jsonb;

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
        _message: = 
        $$
                {
                    "message":"transactions already exist under source profile, cannot change the definition"
                    ,"status":"error"
                }
        $$::jsonb;
        return _message;
    END IF;

    /*-----------------schema validation---------------------
    yeah dont feel like it right now
    ---------------------------------------------------------*/
    
    INSERT INTO
        tps.srce
    SELECT
        _name, _defn
    ON CONFLICT DO UPDATE
        SET
            defn = _defn;


END;
$f$
LANGUAGE plpgsql
