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