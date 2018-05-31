--transactions with date in download format for constraint
COPY
(
SELECT
	to_char(r."AsOfDate",'mm/dd/yyyy') "AsOfDate"
	,r."BankId"
	,r."AccountNumber"
	,r."AccountName"
	,r."BaiControl"
	,r."Currency"
	,r."Transaction"
	,r."Reference"
	,r."Amount"
	,r."Description"
FROM
	tps.trans
	JOIN LATERAL jsonb_populate_record(NULL::tps.pncc, rec) r ON TRUE
WHERE
	srce = 'PNCC'
)
TO 'C:\users\ptrowbridge\downloads\pncc.csv' WITH (format csv, header TRUE)

--source
SELECT DEFN FROM TPS.SRCE WHERE SRCE = 'PNCC'

--mapdef
SELECT jsonb_agg(row_to_json(x)::jsonb) FROM (SELECT srce, target "name", regex, seq "sequence" FROM tps.map_rm WHERE srce = 'PNCC') x

--map values
SELECT jsonb_agg(row_to_JSON(x)::jsonb) FROM (SELECT srce "source", target "map", retval ret_val, "map" mapped FROM tps.map_rv WHERE srce = 'PNCC') X


