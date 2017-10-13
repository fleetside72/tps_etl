DO $$

declare _t text;

begin
	
----------------------------------------------------build the column list of the temp table----------------------------------------------------------------

	SELECT
        string_agg(quote_ident(prs.key)||' '||prs.type,',')
    INTO
    	_t
    FROM 
        TPS.srce
        --unwrap the schema definition array
        LEFT JOIN LATERAL jsonb_populate_recordset(null::tps.srce_defn_schema, defn->'schema') prs ON TRUE
    WHERE   
        srce = 'PNCL'
    GROUP BY
        srce;
        
----------------------------------------------------add create table verbage in front of column list--------------------------------------------------------

    _t := format('CREATE TEMP TABLE csv_i (%s)', _t);
    raise notice '%', _t;
    

----------------------------------------------------build the table-----------------------------------------------------------------------------------------

    DROP TABLE IF EXISTS csv_i;
    
    EXECUTE _t;

    COPY csv_i FROM 'C:\Users\ptrowbridge\Documents\OneDrive - The HC Companies, Inc\Cash\build_hist\pncl.csv' WITH (HEADER TRUE,DELIMITER ',', FORMAT CSV, ENCODING 'SQL_ASCII',QUOTE '"');

end
$$;

--SELECT row_to_json(csv_i) FROM csv_i;

/*
INSERT INTO
    tps.trans (srce, rec)
SELECT 
    'PNCO', row_to_json(csv_i) FROM csv_i;
*/


SELECT
    (row_to_json(i)::jsonb) #> ae.e::text[],
    srce,
    defn->'unique_constraint'->'type',
    defn->'unique_constraint'->'fields',
    ae.e,
    ae.rn
FROM
    csv_i i
    INNER JOIN tps.srce s ON
        s.srce = 'PNCL'
    LEFT JOIN LATERAL JSONB_ARRAY_ELEMENTS_TEXT(defn->'unique_constraint'->'fields') WITH ORDINALITY ae(e, rn) ON TRUE
LIMIT 10