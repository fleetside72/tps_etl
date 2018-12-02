--transactions with date in download format for constraint
--transactions with date in download format for constraint
COPY
(
SELECT
	r."Schedule#"
	,to_char(r."PostDate",'mm/dd/yyyy') "PostDate"
	,r."Assn#"
	,r."Coll#"
	,COALESCE(r."AdvanceRate",0) "AdvanceRate"
	,COALESCE(r."Sales",0) "Sales"
	,COALESCE(r."Credits & Adjustments",0) "Credits & Adjustments"
	,COALESCE(r."Gross Collections",0) "Gross Collections"
	,COALESCE(r."CollateralBalance",0) "CollateralBalance"
	,COALESCE(r."MaxEligible",0) "MaxEligible"
	,COALESCE(r."Ineligible Amount",0) "Ineligible Amount"
	,COALESCE(r."Reserve Amount",0) "Reserve Amount"
FROM
	tps.trans
	JOIN LATERAL jsonb_populate_record(NULL::tps.pncl, rec) r ON TRUE
WHERE
	srce = 'PNCL'
    --and case when rec->>'Credits & Adjustments' is null then 'null' else '' end <> 'null'
)
TO 'C:\users\ptrowbridge\downloads\pncl.csv' WITH (format csv, header TRUE)

--source
SELECT DEFN FROM TPS.SRCE WHERE SRCE = 'PNCL'


