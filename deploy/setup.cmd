"C:\PostgreSQL\pg10\bin\psql" -h localhost -p 5433 -d postgres -U postgres -c "DROP DATABASE ubm2"
"C:\PostgreSQL\pg10\bin\psql" -h localhost -p 5433 -d postgres -U postgres -c "CREATE DATABASE ubm2"
"C:\PostgreSQL\pg10\bin\psql" -h localhost -p 5433 -d ubm2 -U postgres -f "C:\users\fleet\documents\tps_etl\deploy\ubm_schema.sql"

"/home/ubuntu/workspace/bigsql/pg10/bin/psql" -h localhost -p 5432 -d postgres -U postgres -c "DROP DATABASE ubm"
"/home/ubuntu/workspace/bigsql/pg10/bin/psql" -h localhost -p 5432 -d postgres -U postgres -c "CREATE DATABASE ubm"
"/home/ubuntu/workspace/bigsql/pg10/bin/psql" -h localhost -p 5432 -d ubm -U postgres -f "/home/ubuntu/workspace/tps_etl/ubm_schema.sql"