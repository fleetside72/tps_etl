\timing
DROP FUNCTION tps.srce_import(_path text, _srce text);
CREATE OR REPLACE FUNCTION tps.srce_import(_path text, _srce text) RETURNS jsonb

/*--------------------------------------------------------
0. load target import to temp table
1. create pending list
2. get unqiue pending keys
3. see which keys not already in tps.trans
4. insert pending records associated with keys that are not already in trans
5. insert summary to log table
*/---------------------------------------------------------

--to-do
--return infomation to a client via json or composite type


AS $f$
DECLARE _t text;
DECLARE _c text;
DECLARE _log_info jsonb;
DECLARE _log_id text;
DECLARE _cnt numeric;
DECLARE _message jsonb;
_MESSAGE_TEXT text;
_PG_EXCEPTION_DETAIL text;
_PG_EXCEPTION_HINT text;

BEGIN

    --_path := 'C:\users\fleet\downloads\discover-recentactivity-20171031.csv';
    --_srce := 'DCARD';

----------------------------------------------------test if source exists----------------------------------------------------------------------------------

    SELECT
        COUNT(*)
    INTO
        _cnt
    FROM
        tps.srce    
    WHERE
        srce = _srce;

    IF _cnt = 0 THEN
        _message:= 
        format(
            $$
                {
                    "status":"fail",
                    "message":"source %L does not exists"
                }
            $$,
            _srce
        )::jsonb;
        RETURN _message;
    END IF;
----------------------------------------------------build the column list of the temp table----------------------------------------------------------------

	SELECT
        string_agg(quote_ident(prs.key)||' '||prs.type,','),
        string_agg(quote_ident(prs.key),',')
    INTO
    	_t, 
        _c
    FROM 
        tps.srce
        --unwrap the schema definition array
        LEFT JOIN LATERAL jsonb_populate_recordset(null::tps.srce_defn_schema, defn->'schema') prs ON TRUE
    WHERE   
        srce = _srce
    GROUP BY
        srce;
        
----------------------------------------------------add create table verbage in front of column list--------------------------------------------------------

    _t := format('CREATE TEMP TABLE csv_i (%s, id SERIAL)', _t);
    --RAISE NOTICE '%', _t;
    --RAISE NOTICE '%', _c;

    DROP TABLE IF EXISTS csv_i;
    
    EXECUTE _t;

----------------------------------------------------do the insert-------------------------------------------------------------------------------------------

    --the column list needs to be dynamic forcing this whole line to be dynamic
    _t := format('COPY csv_i (%s) FROM %L WITH (HEADER TRUE,DELIMITER '','', FORMAT CSV, ENCODING ''SQL_ASCII'',QUOTE ''"'');',_c,_path);

    --RAISE NOTICE '%', _t;

    BEGIN
        EXECUTE _t;
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
        return _message;
    END;

    WITH 

    -------------extract the limiter fields to one row per source----------------------------------

    ext AS (
    SELECT 
        srce
        ,defn->'unique_constraint'->>'fields'
        ,ARRAY(SELECT ae.e::text[] FROM jsonb_array_elements_text(defn->'unique_constraint'->'fields') ae(e)) text_array
    FROM
        tps.srce
    WHERE
        srce = _srce
        --add where clause for targeted source
    )

    -------------for each imported row in the COPY table, genereate the json rec, and a column for the json key specified in the srce.defn-----------

    ,pending_list AS (
        SELECT
            tps.jsonb_extract(
                    row_to_json(i)::jsonb
                    ,ext.text_array
            ) json_key,
            row_to_json(i)::JSONB rec,
            srce,
            --ae.rn,
            id
        FROM
            csv_i i
            INNER JOIN ext ON
                ext.srce = _srce
        ORDER BY    
            id ASC
    )

    -----------create a unique list of keys from staged rows------------------------------------------------------------------------------------------

    , pending_keys AS (
        SELECT DISTINCT
            json_key
        FROM 
            pending_list
    )

    -----------list of keys already loaded to tps-----------------------------------------------------------------------------------------------------

    , matched_keys AS (
        SELECT DISTINCT
            k.json_key
        FROM
            pending_keys k
            INNER JOIN tps.trans t ON
                t.rec @> k.json_key
    )

    -----------return unique keys that are not already in tps.trans-----------------------------------------------------------------------------------

    , unmatched_keys AS (
    SELECT
        json_key
    FROM
        pending_keys

    EXCEPT

    SELECT
        json_key
    FROM
        matched_keys
    )

    -----------insert pending rows that have key with no trans match-----------------------------------------------------------------------------------
    --need to look into mapping the transactions prior to loading

    , inserted AS (
        INSERT INTO
            tps.trans (srce, rec)
        SELECT
            pl.srce
            ,pl.rec
        FROM 
            pending_list pl
            INNER JOIN unmatched_keys u ON
                u.json_key = pl.json_key
        ORDER BY
            pl.id ASC
        ----this conflict is only if an exact duplicate rec json happens, which will be rejected
        ----therefore, records may not be inserted due to ay matches with certain json fields, or if the entire json is a duplicate, reason is not specified
        RETURNING *
    )

    --------summarize records not inserted-------------------+------------------------------------------------------------------------------------------------

    , logged AS (
    INSERT INTO
        tps.trans_log (info)
    SELECT
        JSONB_BUILD_OBJECT('time_stamp',CURRENT_TIMESTAMP)
        ||JSONB_BUILD_OBJECT('srce',_srce)
        ||JSONB_BUILD_OBJECT('path',_path)
        ||JSONB_BUILD_OBJECT('not_inserted',
            (
                SELECT 
                    jsonb_agg(json_key)
                FROM
                    matched_keys
            )
        )
        ||JSONB_BUILD_OBJECT('inserted',
            (
                SELECT 
                    jsonb_agg(json_key)
                FROM
                    unmatched_keys
            )
        )
    RETURNING *
    )

    SELECT
        id
        ,info
    INTO
        _log_id
        ,_log_info
    FROM
        logged;

    --RAISE NOTICE 'import logged under id# %, info: %', _log_id, _log_info;

    _message:= 
    (
        format(
        $$
            {
            "status":"complete",
            "message":"import of %L for source %L complete"
            }
        $$, _path, _srce)::jsonb
    )||jsonb_build_object('details',_log_info);

    RETURN _message;
END
$f$
LANGUAGE plpgsql

