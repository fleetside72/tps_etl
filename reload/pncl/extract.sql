--transactions with date in download format for constraint
--transactions with date in download format for constraint
COPY
(
SELECT
	r."Schedule#"
	,to_char(r."PostDate",'mm/dd/yyyy') "Post Date"
	,r."Assn#"
	,r."Coll#"
	,r."AdvanceRate"
	,r."Sales"
	,r."Credits & Adjustments"
	,r."Gross Collections"
	,r."CollateralBalance"
	,r."MaxEligible"
	,r."Ineligible Amount"
	,r."Reserve Amount"
FROM
	tps.trans
	JOIN LATERAL jsonb_populate_record(NULL::tps.pncl, rec) r ON TRUE
WHERE
	srce = 'PNCL'
)
TO 'C:\users\ptrowbridge\downloads\pncl.csv' WITH (format csv, header TRUE)

--source
SELECT DEFN FROM TPS.SRCE WHERE SRCE = 'PNCL'


