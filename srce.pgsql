\timing

/*--------------------------------------------------------
0. load target import to temp table
1. create pending list
2. get unqiue pending keys
3. see which keys not already in tps.trans
4. insert pending records associated with keys that are not already in trans
5. get list of recors not inserted
6. summarize records not inserted
*/---------------------------------------------------------


DO $$

DECLARE _t text;
DECLARE _c text;
DECLARE _path text;
DECLARE _srce text;

BEGIN

    _path := 'C:\users\ptrowbridge\downloads\lon_loan_ledgerbal.csv';
    _srce := 'PNCO';
	
----------------------------------------------------build the column list of the temp table----------------------------------------------------------------

	SELECT
        string_agg(quote_ident(prs.key)||' '||prs.type,','),
        string_agg(quote_ident(prs.key),',')
    INTO
    	_t, 
        _c
    FROM 
        TPS.srce
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

    EXECUTE _t;

    WITH 

    -------------for each imported row in the COPY table, genereate the json rec, and a column for the json key specified in the srce.defn-----------

    pending_list AS (
        SELECT
            ---creates a key value pair and then aggregates rows of key value pairs
            jsonb_object_agg(
                    (ae.e::text[])[1],                                  --the key name
                    (row_to_json(i)::jsonb) #> ae.e::text[]             --get the target value from the key from the csv row that has been converted to json
            ) json_key,
            row_to_json(i)::JSONB rec,
            srce,
            --ae.rn,
            id
        FROM
            csv_i i
            INNER JOIN tps.srce s ON
                s.srce = _srce
            LEFT JOIN LATERAL JSONB_ARRAY_ELEMENTS_TEXT(defn->'unique_constraint'->'fields') WITH ORDINALITY ae(e, rn) ON TRUE
        GROUP BY
            i.*,
            srce,
            id
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

    -----------return unique keys that are not already in tps.trans-----------------------------------------------------------------------------------

    , unmatched_keys AS (
    SELECT
        json_key
    FROM
        pending_keys

    EXCEPT

    SELECT DISTINCT
        k.json_key
    FROM
        pending_keys k
        INNER JOIN tps.trans t ON
            t.rec @> k.json_key
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

    -----------list of records not inserted--------------------------------------------------------------------------------------------------------------

    , not_inserted AS (
        SELECT
            srce
            ,rec
        FROM
            pending_list

        EXCEPT ALL

        SELECT 
            srce
            ,rec
        FROM 
            inserted
    )

    --------insert to log-------------------------------------------------------------------------------------------------------------------------------------
    --below select should be loaded to the log table



    --------summarize records not inserted-------------------+------------------------------------------------------------------------------------------------

    SELECT
        t.srce
        ,(ae.e::text[])[1] unq_constr
        ,MIN(rec #>> ae.e::text[]) min_text
        ,MAX(rec #>> ae.e::text[]) max_text
        ,JSONB_PRETTY(JSON_AGG(rec #> ae.e::text[] ORDER BY rec #>> ae.e::text[])::JSONB)
    FROM
        not_inserted t
        INNER JOIN tps.srce s ON
            s.srce = t.srce
        LEFT JOIN LATERAL JSONB_ARRAY_ELEMENTS_TEXT(defn->'unique_constraint'->'fields') WITH ORDINALITY ae(e, rn) ON TRUE
    GROUP BY
        t.srce
        ,(ae.e::text[])[1];

END
$$;