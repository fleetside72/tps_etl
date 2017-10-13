
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
        srce = 'DCARD'
    GROUP BY
        srce;
        
----------------------------------------------------add create table verbage in front of column list--------------------------------------------------------

    _t := format('CREATE TEMP TABLE csv_i (%s)', _t);
    raise notice '%', _t;
    

----------------------------------------------------build the table-----------------------------------------------------------------------------------------

    DROP TABLE IF EXISTS csv_i;
    
    EXECUTE _t;

    COPY csv_i FROM 'C:\Users\fleet\downloads\dc.csv' WITH (HEADER TRUE,DELIMITER ',', FORMAT CSV, ENCODING 'SQL_ASCII',QUOTE '"');


end
$$;

SELECT * FROM csv_i;



/*
INSERT INTO
    tps.trans (srce, rec)
SELECT 
    'DCARD', row_to_json(csv_i) FROM csv_i;
*/