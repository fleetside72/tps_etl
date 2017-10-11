--
-- PostgreSQL database dump
--

-- Dumped from database version 10rc1
-- Dumped by pg_dump version 10rc1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'WIN1252';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: evt; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA evt;


--
-- Name: SCHEMA evt; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA evt IS 'events';


--
-- Name: tps; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA tps;


--
-- Name: SCHEMA tps; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA tps IS 'third party source';


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = tps, pg_catalog;

--
-- Name: srce_defn_schema; Type: TYPE; Schema: tps; Owner: -
--

CREATE TYPE srce_defn_schema AS (
	key text,
	type text
);


SET search_path = evt, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: log; Type: TABLE; Schema: evt; Owner: -
--

CREATE TABLE log (
    id integer NOT NULL,
    rec jsonb
);


--
-- Name: log_id_seq; Type: SEQUENCE; Schema: evt; Owner: -
--

ALTER TABLE log ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


SET search_path = tps, pg_catalog;

--
-- Name: srce; Type: TABLE; Schema: tps; Owner: -
--

CREATE TABLE srce (
    srce text NOT NULL,
    defn jsonb
);


--
-- Name: trans; Type: TABLE; Schema: tps; Owner: -
--

CREATE TABLE trans (
    id integer NOT NULL,
    srce text,
    rec jsonb,
    map jsonb
);


--
-- Name: trans_id_seq; Type: SEQUENCE; Schema: tps; Owner: -
--

ALTER TABLE trans ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME trans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


SET search_path = evt, pg_catalog;

--
-- Name: log log_pkey; Type: CONSTRAINT; Schema: evt; Owner: -
--

ALTER TABLE ONLY log
    ADD CONSTRAINT log_pkey PRIMARY KEY (id);


SET search_path = tps, pg_catalog;

--
-- Name: srce srce_pkey; Type: CONSTRAINT; Schema: tps; Owner: -
--

ALTER TABLE ONLY srce
    ADD CONSTRAINT srce_pkey PRIMARY KEY (srce);


--
-- Name: trans trans_pkey; Type: CONSTRAINT; Schema: tps; Owner: -
--

ALTER TABLE ONLY trans
    ADD CONSTRAINT trans_pkey PRIMARY KEY (id);


--
-- Name: trans trans_srce_fkey; Type: FK CONSTRAINT; Schema: tps; Owner: -
--

ALTER TABLE ONLY trans
    ADD CONSTRAINT trans_srce_fkey FOREIGN KEY (srce) REFERENCES srce(srce);


--
-- PostgreSQL database dump complete
--

