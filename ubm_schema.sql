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


--
-- Name: plprofiler; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plprofiler WITH SCHEMA public;


--
-- Name: EXTENSION plprofiler; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plprofiler IS 'server-side support for profiling PL/pgSQL functions';


SET search_path = tps, pg_catalog;

--
-- Name: pncl; Type: TYPE; Schema: tps; Owner: -
--

CREATE TYPE pncl AS (
	"Schedule#" text,
	"PostDate" date,
	"Assn#" text,
	"Coll#" text,
	"AdvanceRate" numeric,
	"Sales" numeric,
	"Credits & Adjustments" numeric,
	"Gross Collections" numeric,
	"CollateralBalance" numeric,
	"MaxEligible" numeric,
	"Ineligible Amount" numeric,
	"Reserve Amount" numeric
);


--
-- Name: pnco; Type: TYPE; Schema: tps; Owner: -
--

CREATE TYPE pnco AS (
	"Loan#" text,
	"Post Date" date,
	"Effective Date" date,
	"Reference #" text,
	"Description" text,
	"Advances" numeric,
	"Adjustments" numeric,
	"Payments" numeric,
	"Loan Balance" numeric
);


--
-- Name: srce_defn_schema; Type: TYPE; Schema: tps; Owner: -
--

CREATE TYPE srce_defn_schema AS (
	key text,
	type text
);


--
-- Name: jsonb_concat(jsonb, jsonb); Type: FUNCTION; Schema: tps; Owner: -
--

CREATE FUNCTION jsonb_concat(state jsonb, concat jsonb) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
BEGIN
	--RAISE notice 'state is %', state;
	--RAISE notice 'concat is %', concat;
	RETURN state || concat;
END;
$$;


--
-- Name: jsonb_concat_obj(jsonb); Type: AGGREGATE; Schema: tps; Owner: -
--

CREATE AGGREGATE jsonb_concat_obj(jsonb) (
    SFUNC = jsonb_concat,
    STYPE = jsonb,
    INITCOND = '{}'
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
-- Name: map_rm; Type: TABLE; Schema: tps; Owner: -
--

CREATE TABLE map_rm (
    srce text NOT NULL,
    target text NOT NULL,
    regex jsonb,
    seq integer NOT NULL
);


--
-- Name: map_rv; Type: TABLE; Schema: tps; Owner: -
--

CREATE TABLE map_rv (
    srce text NOT NULL,
    target text NOT NULL,
    retval jsonb NOT NULL,
    map jsonb
);


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


--
-- Name: trans_log; Type: TABLE; Schema: tps; Owner: -
--

CREATE TABLE trans_log (
    id integer NOT NULL,
    info jsonb
);


--
-- Name: trans_log_id_seq; Type: SEQUENCE; Schema: tps; Owner: -
--

ALTER TABLE trans_log ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME trans_log_id_seq
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
-- Name: map_rm map_rm_pk; Type: CONSTRAINT; Schema: tps; Owner: -
--

ALTER TABLE ONLY map_rm
    ADD CONSTRAINT map_rm_pk PRIMARY KEY (srce, target);


--
-- Name: map_rv map_rv_pk; Type: CONSTRAINT; Schema: tps; Owner: -
--

ALTER TABLE ONLY map_rv
    ADD CONSTRAINT map_rv_pk PRIMARY KEY (srce, target, retval);


--
-- Name: srce srce_pkey; Type: CONSTRAINT; Schema: tps; Owner: -
--

ALTER TABLE ONLY srce
    ADD CONSTRAINT srce_pkey PRIMARY KEY (srce);


--
-- Name: trans_log trans_log_pkey; Type: CONSTRAINT; Schema: tps; Owner: -
--

ALTER TABLE ONLY trans_log
    ADD CONSTRAINT trans_log_pkey PRIMARY KEY (id);


--
-- Name: trans trans_pkey; Type: CONSTRAINT; Schema: tps; Owner: -
--

ALTER TABLE ONLY trans
    ADD CONSTRAINT trans_pkey PRIMARY KEY (id);


--
-- Name: trans_rec; Type: INDEX; Schema: tps; Owner: -
--

CREATE INDEX trans_rec ON trans USING gin (rec);


--
-- Name: map_rm map_rm_fk_srce; Type: FK CONSTRAINT; Schema: tps; Owner: -
--

ALTER TABLE ONLY map_rm
    ADD CONSTRAINT map_rm_fk_srce FOREIGN KEY (srce) REFERENCES srce(srce);


--
-- Name: map_rv map_rv_fk_rm; Type: FK CONSTRAINT; Schema: tps; Owner: -
--

ALTER TABLE ONLY map_rv
    ADD CONSTRAINT map_rv_fk_rm FOREIGN KEY (srce, target) REFERENCES map_rm(srce, target);


--
-- Name: trans trans_srce_fkey; Type: FK CONSTRAINT; Schema: tps; Owner: -
--

ALTER TABLE ONLY trans
    ADD CONSTRAINT trans_srce_fkey FOREIGN KEY (srce) REFERENCES srce(srce);


--
-- PostgreSQL database dump complete
--

