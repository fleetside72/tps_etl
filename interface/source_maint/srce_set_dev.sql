DO $f$

DECLARE
_defn jsonb;
_cnt int;
_conflict BOOLEAN;
_message jsonb;
_sql text;
_cur_sch jsonb;

BEGIN

    SELECT  
        $$
        {
            "name":"dcard",
            "source":"client_file",
            "loading_function":"csv",
            "constraint":[
                "{Trans. Date}",
                "{Post Date}"
            ],
            "schemas":{
                "default":[
                    {
                        "path":"{Trans. Date}",
                        "type":"date",
                        "column_name":"Trans. Date"
                    },
                    {
                        "path":"{Post Date}",
                        "type":"date",
                        "column_name":"Post Date"
                    },
                    {
                        "path":"{Description}",
                        "type":"text",
                        "column_name":"Description"
                    },
                    {
                        "path":"{Amount}",
                        "type":"numeric",
                        "column_name":"Amount"
                    },
                    {
                        "path":"{Category}",
                        "type":"text",
                        "column_name":"Category"
                    }
                ],
                "version2":[]
            }
        }
        $$
    INTO
        _defn;

/*
validate schema? should not need validation if created by ui




*/

    -------extract current source schema for compare--------------------------
    SELECT
        defn#>'{schemas,default}'
    INTO
        _cur_sch
    FROM
        tps.srce
    WHERE
        srce = _defn->>'name';


    /*-------------------------------------------------------
    do schema validation
    ---------------------------------------------------------*/
    
    -------------------insert definition----------------------------------------
    INSERT INTO
        tps.srce
    SELECT
        _defn->>'name', _defn
    ON CONFLICT ON CONSTRAINT srce_pkey DO UPDATE
        SET
            defn = _defn;
    

    
    _message = 
        $$
                {
    "message": "definition set",
    "status": "success"
}
        $$: :jsonb;
    return _message;

END;
$f$
LANGUAGE plpgsql
