psql -U ptrowbridge -d ubm -p 5432 -h ushcc10091 -c "COPY (SELECT jsonb_agg(rec) rec from tps.trans where srce = 'PNCC') TO 'c:\users\ptrowbridge\downloads\pncc.csv' WITH (format csv, header true)"
psql -U ptrowbridge -d ubm_dev -p 5432 -h ushcc10091 -c "CREATE TEMP TABLE x(j jsonb); COPY x FROM 'c:\users\ptrowbridge\downloads\pncc.csv' with (format csv, header true); SELECT * FROM x JOIN LATERAL tps.srce_import('PNCC',x.j) ON TRUE; DROP TABLE X;"