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