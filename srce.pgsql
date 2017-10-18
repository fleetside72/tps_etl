DO $$

DECLARE _t text;
DECLARE _c text;

BEGIN
	
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
        srce = 'PNCC'
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
    _t := format('COPY csv_i (%s) FROM ''C:\Users\ptrowbridge\downloads\transsearchcsv.csv'' WITH (HEADER TRUE,DELIMITER '','', FORMAT CSV, ENCODING ''SQL_ASCII'',QUOTE ''"'');',_c);

    --RAISE NOTICE '%', _t;

    EXECUTE _t;


END
$$;

--*******************************************
--this needs to aggregate on id sequence
--*******************************************
WITH pending_list AS (
    SELECT
        ---creates a key value pair and then aggregates rows of key value pairs
        jsonb_object_agg(
                (ae.e::text[])[1],                                  --the key name
                (row_to_json(i)::jsonb) #> ae.e::text[]             --get the target value from the key from the csv row that has been converted to json
        ) json_key,
        row_to_json(i)::JSONB - 'id' rec,
        srce,
        --ae.rn,
        id
    FROM
        csv_i i
        INNER JOIN tps.srce s ON
            s.srce = 'PNCC'
        LEFT JOIN LATERAL JSONB_ARRAY_ELEMENTS_TEXT(defn->'unique_constraint'->'fields') WITH ORDINALITY ae(e, rn) ON TRUE
    GROUP BY
        i.*,
        srce,
        id
    ORDER BY    
        id
)
------results of an insert operation--------------
, inserted AS (
    INSERT INTO
        tps.trans (srce, rec)
    SELECT
        pl.srce
        ,pl.rec
    FROM 
        pending_list pl
        LEFT JOIN tps.trans t ON
            t.srce = pl.srce
            AND t.rec @> pl.json_key
        WHERE
            t IS NULL
    ----this conflict is only if an exact duplicate rec json happens, which will be rejected
    ----therefore, records may not be inserted due to ay matches with certain json fields, or if the entire json is a duplicate, reason is not specified
    RETURNING *
)
---------raw list of records not inserted----------
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
--------summarize records not inserted------------------
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