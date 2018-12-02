--transactions with date in download format for constraint
--transactions with date in download format for constraint
COPY
(
SELECT
	r."Loan#"
	,to_char(r."Post Date",'mm/dd/yyyy') "Post Date"
	,to_char(r."Effective Date",'mm/dd/yyyy') "Effective Date"
	,r."Reference #"
	,r."Description"
	,r."Advances"
	,r."Adjustments"
	,r."Payments"
	,r."Loan Balance"
FROM
	tps.trans
	JOIN LATERAL jsonb_populate_record(NULL::tps.pnco, rec) r ON TRUE
WHERE
	srce = 'PNCO'
)
TO 'C:\users\ptrowbridge\downloads\pnco.csv' WITH (format csv, header TRUE)

--source
SELECT DEFN FROM TPS.SRCE WHERE SRCE = 'PNCO'

--mapdef
SELECT jsonb_agg(row_to_json(x)::jsonb) FROM (SELECT srce, target "name", regex, seq "sequence" FROM tps.map_rm WHERE srce = 'PNCO') x

--map values
SELECT jsonb_agg(row_to_JSON(x)::jsonb) FROM (SELECT srce "source", target "map", retval ret_val, "map" mapped FROM tps.map_rv WHERE srce = 'PNCO') X


