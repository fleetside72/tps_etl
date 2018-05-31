--source
COPY (SELECT DEFN FROM TPS.SRCE WHERE SRCE = 'HUNT') TO 'C:\users\fleet\documents\tps_etl\reload\hunt\srce.json' WITH (FORMAT TEXT, HEADER FALSE)

--mapdef
COPY (SELECT jsonb_agg(row_to_json(x)::jsonb) FROM (SELECT srce, target "name", regex, seq "sequence" FROM tps.map_rm WHERE srce = 'HUNT') x) TO 'C:\users\fleet\documents\tps_etl\reload\hunt\map.json' WITH (FORMAT TEXT, HEADER FALSE)

--map values
SELECT jsonb_agg(row_to_JSON(x)::jsonb) FROM (SELECT srce "source", target "map", retval ret_val, "map" mapped FROM tps.map_rv WHERE srce = 'HUNT') X

--records
copy (
    select 
        to_char(r."Date",'mm/dd/yy') "Date"
        ,r."Reference Number"
        ,r."Payee Name"
        ,r."Memo"
        ,r."Amount"
		,r."Category Name"
    from
        tps.trans 
        join lateral jsonb_populate_record(null::tps.hunt, rec) r on true 
    where 
        srce = 'HUNT'
	order by 
		r."Date" asc
) to 
'C:\users\fleet\downloads\hunt.csv' with (format csv, header true);
