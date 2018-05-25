create temp table x as (
select
	t.rec
from
	generate_series(1,1000000,1) s
	inner join tps.trans t on
		srce = 'DMAPI'
) with data;


create temp table x2 as (	
select
	(
		rec #>>(
			'{doc,origin_addresses,0}'::text[]
		)
	)::text as origin_address,
	(
		rec #>>(
			'{doc,destination_addresses,0}'::text[]
		)
	)::text as desatination_address,
	(
		rec #>>(
			'{doc,status}'::text[]
		)
	)::text as status,
	(
		rec #>>(
			'{doc,rows,0,elements,0,distance,value}'::text[]
		)
	)::numeric as distance,
	(
		rec #>>(
			'{doc,rows,0,elements,0,duration,value}'::text[]
		)
	)::numeric as duration
from
	x
) with data;
	

drop table x;
drop table x2;