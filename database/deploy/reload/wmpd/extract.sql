--source
COPY (SELECT DEFN FROM TPS.SRCE WHERE SRCE = 'WMPD') TO 'C:\users\ptrowbridge\documents\tps_etl\deploy\reload\wmpd\srce.json' WITH (FORMAT TEXT, HEADER FALSE)

--mapdef
COPY (SELECT jsonb_agg(row_to_json(x)::jsonb) FROM (SELECT srce, target "name", regex, seq "sequence" FROM tps.map_rm WHERE srce = 'WMPD') x) TO 'C:\users\ptrowbridge\documents\tps_etl\deploy\reload\wmpd\map.json' WITH (FORMAT TEXT, HEADER FALSE)

--map values
SELECT jsonb_agg(row_to_JSON(x)::jsonb) FROM (SELECT srce "source", target "map", retval ret_val, "map" mapped FROM tps.map_rv WHERE srce = 'WMPD') X

--records
copy (
    select 
        r."Carrier",
        r."SCAC",
        r."Mode",
        r."Pro #",
        r."B/L",
        r."Pd Amt",
        r."Loc#",
        r."Pcs",
        r."Wgt",
        r."Chk#",
        r."Pay Dt",
        r."Acct #",
        r."I/O",
        r."Sh Nm",
        r."Sh City",
        r."Sh St",
        r."Sh Zip",
        r."Cons Nm",
        r."D City ",
        r."D St",
        r."D Zip",
        r."Sh Dt",
        r."Inv Dt",
        r."Customs Entry#",
        r."Miles",
        r."Frt Class",
        r."Master B/L"
    from
        tps.trans 
        join lateral jsonb_populate_record(null::tps.WMPD, rec) r on true 
    where 
        srce = 'WMPD'
	order by 
		r."Pay Dt" asc
) to 
'C:\users\ptrowbridge\downloads\WMPD.csv' with (format csv, header true);

--rebuild source def to include PATH
SELECT
	ae.r
	||jsonb_build_object(
		'path',
		(
			'{'||(ae.r->>'column_name')||'}'
		)
	)
FROM
	tps.srce
	JOIN LATERAL jsonb_array_elements(defn->'schemas'->'default') ae(r) ON TRUE
WHERE
	srce = 'WMPD'
