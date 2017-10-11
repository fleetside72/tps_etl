/*
SELECT
jsonb_pretty(
$$
{
    "name": "GOOGDM",
    "type": "json_csv",
    "schema": {
        "rows": [
            {
                "elements": [
                    {
                        "status": "text",
                        "distance": {
                            "text": "text",
                            "value": "numeric"
                        },
                        "duration": {
                            "text": "text",
                            "value": "value"
                       }
                    }
                ]
            }
        ],
        "status": "text",
        "origin_addresses": [
            "text"
        ],
        "destination_addresses": [
            "text"
        ]
    },
    "unique_constraint": {
        "type": "key",
        "fields": [
            "{origin_adresses,0}",
            "{destination_adresses,0}"
        ]
    }
}
$$::jsonb
)
*/

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
        srce = 'PNCO'
    GROUP BY
        srce;
        
----------------------------------------------------add create table verbage in front of column list--------------------------------------------------------

    _t := format('CREATE TEMP TABLE csv_i (%s)', _t);
    raise notice '%', _t;
    

----------------------------------------------------build the table-----------------------------------------------------------------------------------------

    DROP TABLE IF EXISTS csv_i;
    
    EXECUTE _t;

end
$$;

--SELECT * FROM csv_i;

COPY csv_i FROM 'C:\Users\ptrowbridge\Documents\OneDrive - The HC Companies, Inc\Cash\build_hist\full_dl\15Q1bal.csv' WITH (HEADER TRUE,DELIMITER ',', FORMAT CSV, ENCODING 'SQL_ASCII',QUOTE '"');

INSERT INTO
    tps.trans (srce, rec)
SELECT 
    'PNCO', row_to_json(csv_i) FROM csv_i;