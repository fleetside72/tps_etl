--transactions with date in download format for constraint
COPY
(
SELECT
	r."perd_start",
	r."perd_end",
	r."check_date",
	r."loc_code",
	r."loc_descr",
	r."loc_glseg",
	r."loc_over",
	r."dep_code",
	r."dep_descr",
	r."dep_nat",
	r."dep_over",
	r."di_code",
	r."di_descr",
	r."di_glseg",
	r."di_over",
	r."title_code",
	r."title_descr",
	r."title_glseg",
	r."title_over",
	r."ee_code",
	r."ee_glseg",
	r."ee_over",
	r."acct_type_code",
	r."hours",
	r."nat_code",
	r."nat_over",
	r."gl_ref",
	r."gl_group",
	r."gl_descr",
	r."gl_code",
	r."gl_amount",
	r."pp_code",
	r."pp_descr",
	r."pp_gl",
	r."pp_over",
	r."transaction"
FROM
	tps.trans
	JOIN LATERAL jsonb_populate_record(NULL::tps.PAYCOM, rec) r ON TRUE
WHERE
	srce = 'PAYCOM'
)
TO 'C:\users\ptrowbridge\downloads\PAYCOM.csv' WITH (format csv, header TRUE)

--source
SELECT DEFN FROM TPS.SRCE WHERE SRCE = 'PAYCOM'

--mapdef
SELECT jsonb_agg(row_to_json(x)::jsonb) FROM (SELECT srce, target "name", regex, seq "sequence" FROM tps.map_rm WHERE srce = 'PAYCOM') x

--map values
SELECT jsonb_agg(row_to_JSON(x)::jsonb) FROM (SELECT srce "source", target "map", retval ret_val, "map" mapped FROM tps.map_rv WHERE srce = 'PAYCOM') X


