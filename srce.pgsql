
DO $$

declare _t text;
declare _c text;

begin
	
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
        srce = 'DCARD'
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
    _t := format('COPY csv_i (%s) FROM ''C:\Users\fleet\downloads\dc.csv'' WITH (HEADER TRUE,DELIMITER '','', FORMAT CSV, ENCODING ''SQL_ASCII'',QUOTE ''"'');',_c);

    --RAISE NOTICE '%', _t;

    EXECUTE _t;


end
$$;

--this needs to aggregate on id sequence
SELECT
    jsonb_build_object(
            (ae.e::text[])[1],                                  --the key name
            (row_to_json(i)::jsonb) #> ae.e::text[]             --get the target value from the key from the csv row that has been converted to json
    ) json_key,
    srce,
    ae.rn,
    id
FROM
    csv_i i
    INNER JOIN tps.srce s ON
        s.srce = 'DCARD'
    LEFT JOIN LATERAL JSONB_ARRAY_ELEMENTS_TEXT(defn->'unique_constraint'->'fields') WITH ORDINALITY ae(e, rn) ON TRUE;

/*
INSERT INTO
    tps.trans (srce, rec)
SELECT 
    'DCARD', row_to_json(csv_i) FROM csv_i;
*/