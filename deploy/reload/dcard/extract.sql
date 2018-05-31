--source
SELECT DEFN FROM TPS.SRCE WHERE SRCE = 'DCARD'

--mapdef
SELECT jsonb_agg(row_to_json(x)::jsonb) FROM (SELECT srce, target "name", regex, seq "sequence" FROM tps.map_rm WHERE srce = 'DCARD') x

--map values
SELECT jsonb_agg(row_to_JSON(x)::jsonb) FROM (SELECT srce "source", target "map", retval ret_val, "map" mapped FROM tps.map_rv WHERE srce = 'DCARD') X

--records
copy (
    select 
        to_char(r."Trans. Date",'mm/dd/yyyy') "Trans. Date"
        ,to_char(r."Post Date",'mm/dd/yyyy') "Post Date"
        ,r."Description"
        ,r."Amount"
        ,r."Category"
    from
        tps.trans 
        join lateral jsonb_populate_record(null::tps.dcard, rec) r on true 
    where 
        srce = 'DCARD'
) to 
'C:\users\fleet\downloads\dcard.csv' with (format csv, header true);
