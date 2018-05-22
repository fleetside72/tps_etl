------create dev schema and api user-----------------------------------------------------------------------------------------------------------------

DROP SCHEMA IF EXISTS tps_dev;

CREATE SCHEMA tps_dev;

DROP USER IF EXISTS api_dev;

CREATE USER api_dev WITH
	LOGIN
	NOSUPERUSER
	NOCREATEDB
	NOCREATEROLE
	INHERIT
	NOREPLICATION
	CONNECTION LIMIT -1
	PASSWORD 'api_dev';

-----need to setup all database objects and then grant priveledges to api----------------------------------------------------------------------------

GRANT SELECT, UPDATE, INSERT, DELETE ON ALL TABLES IN SCHEMA tps_dev TO api_dev;

GRANT USAGE ON ALL SEQUENCES IN SCHEMA tps_dev TO api_dev;

ALTER DEFAULT PRIVILEGES IN SCHEMA tps_dev GRANT SELECT, UPDATE, INSERT, DELETE ON TABLES TO api_dev;

ALTER DEFAULT PRIVILEGES IN SCHEMA tps_dev GRANT USAGE ON SEQUENCES TO api_dev;

