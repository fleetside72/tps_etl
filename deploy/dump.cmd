"C:\PostgreSQL\pg10\bin\pg_dump" -h localhost -p 5433 -U ptrowbridge -d ubm2 -s -n "tps" -O -F p -f "C:\users\fleet\Documents\tps_etl\deploy\ubm_schema.sql"

"/home/ubuntu/workspace/bigsql/pg10/bin/psql" -h localhost -p 5433 -U ptrowbridge -d ubm -s -n "tps" -O -F p -f "/home/ubuntu/workspace/tps_etl/deploy/ubm_schema.sql"

