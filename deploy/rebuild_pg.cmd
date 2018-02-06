"C:\PostgreSQL\pg10\bin\psql" -h localhost -p 5433 -d postgres -U postgres -c "DROP DATABASE ubm"
"C:\PostgreSQL\pg10\bin\psql" -h localhost -p 5433 -d postgres -U postgres -c "CREATE DATABASE ubm"
"C:\PostgreSQL\pg10\bin\psql" -h localhost -p 5433 -d ubm -U postgres -f "C:\users\fleet\documents\tps_etl\ubm_schema.sql"
"C:\PostgreSQL\pg10\bin\psql" -h localhost -p 5433 -d ubm -U postgres -f "C:\users\fleet\documents\tps_etl\ubm_data.sql"
