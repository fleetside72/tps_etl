DROP FUNCTION IF EXISTS tps.build_srce_view_sql(text, text);
CREATE OR REPLACE FUNCTION tps.build_srce_view_sql(_srce text, _schema text) RETURNS TEXT
AS
$f$
DECLARE	
	--_schema text;
	_path text[];
	--_srce text;
	_sql text;
BEGIN
    --_schema:= 'default';
	_path:= ARRAY['schemas',_schema]::text[];
	--_srce:= 'dcard';
SELECT
	'CREATE VIEW tpsv.'||_srce||'_'||_path[2]||' AS SELECT '||string_agg('(allj#>>'''||r.PATH::text||''')::'||r.type||' AS "'||r.column_name||'"',', ')||' FROM tps.trans WHERE srce = '''||_srce||''''
INTO	
	_sql
FROM
	tps.srce
	JOIN LATERAL jsonb_array_elements(defn#>_path) ae(v) ON TRUE
	JOIN LATERAL jsonb_to_record (ae.v) AS r(PATH text[], "type" text, column_name text) ON TRUE 
WHERE
	srce = _srce
GROUP BY
	srce.srce;

RETURN _sql;
RAISE NOTICE '%',_sql;

END
$f$
LANGUAGE plpgsql;