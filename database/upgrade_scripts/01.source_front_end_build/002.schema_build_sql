DROP FUNCTION IF EXISTS tps.build_srce_view_sql(text, text);
CREATE OR REPLACE FUNCTION tps.build_srce_view_sql(_srce text, _schema text) RETURNS TEXT
AS
$f$
DECLARE	
	--_schema text;
	--_srce text;
	_sql text;
BEGIN
    --_schema:= 'default';
	--_srce:= 'dcard';
SELECT
   'DROP VIEW IF EXISTS tpsv.'||s.srce||'_'||(list.e->>'name')||'; CREATE VIEW tpsv.'||s.srce||'_'||(list.e->>'name')||' AS SELECT id, logid, allj, '||string_agg('(allj#>>'''||rec.PATH::text||''')::'||rec.type||' AS "'||rec.column_name||'"',', ')||' FROM tps.trans WHERE srce = '''||s.srce||''';'
INTO
	_sql
FROM
    tps.srce s
    JOIN LATERAL jsonb_array_elements(s.defn->'schemas') list (e) ON TRUE
    JOIN LATERAL jsonb_array_elements(list.e->'columns') as cols(e) ON TRUE
    JOIN LATERAL jsonb_to_record (cols.e) AS rec( PATH text[], "type" text, column_name text) ON TRUE 
WHERE
    srce = _srce
    AND list.e->>'name' = _schema
GROUP BY
    s.srce
    ,list.e;

RETURN _sql;
RAISE NOTICE '%',_sql;

END
$f$
LANGUAGE plpgsql;