--
-- PostgreSQL database dump
--

-- Dumped from database version 10beta4
-- Dumped by pg_dump version 10beta4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'WIN1252';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: bank; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA bank;


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


SET search_path = bank, pg_catalog;

--
-- Name: pncc; Type: TYPE; Schema: bank; Owner: -
--

CREATE TYPE pncc AS (
	"AsOfDate" date,
	"BankId" text,
	"AccountNumber" text,
	"AccountName" text,
	"BaiControl" text,
	"Currency" text,
	"Transaction" text,
	"Reference" text,
	"Amount" numeric,
	"Description" text,
	"AdditionalRemittance" text
);


SET search_path = tps, pg_catalog;

--
-- Name: dcard; Type: TYPE; Schema: tps; Owner: -
--

CREATE TYPE dcard AS (
	"Trans. Date" date,
	"Post Date" date,
	"Description" text,
	"Amount" numeric,
	"Category" text
);


--
-- Name: hunt; Type: TYPE; Schema: tps; Owner: -
--

CREATE TYPE hunt AS (
	"Date" date,
	"Reference Number" numeric,
	"Payee Name" text,
	"Memo" text,
	"Amount" text,
	"Category Name" text
);


--
-- Name: srce_defn_schema; Type: TYPE; Schema: tps; Owner: -
--

CREATE TYPE srce_defn_schema AS (
	key text,
	type text
);


SET search_path = evt, pg_catalog;

--
-- Name: build_hdr_item_mje_gl(jsonb); Type: FUNCTION; Schema: evt; Owner: -
--

CREATE FUNCTION build_hdr_item_mje_gl(_j jsonb) RETURNS jsonb
    LANGUAGE plpgsql
    AS $_$
DECLARE _m text;

BEGIN

--_j := $${"header":{"vendor":"Target","date":"10/12/2017","instrument":"Discover Card","module":"hdrio","total":47.74,"location":"Stow, OH","transaction":"purchase","offset":"dcard"},"item":[{"vend item":"HERBAL","amt":7.99,"account":"home supplies","item":"shampoo","reason":"hygiene"},{"vend item":"HERBAL","amt":7.99,"account":"home supplies","item":"conditioner","reason":"hygiene"},{"vend item":"BUILDING SET","amt":28.74,"account":"recreation","item":"legos","reason":"toys","qty":6,"uom":"ea"},{"vend item":"OH TAX","amt":3.02,"account":"sales tax","item":"sales tax","reason":"sales tax","rate":"0.0675"}]}$$;

WITH
j AS (
    SELECT
        _j  jb
)

--------build a duplicating cross join table------------------

    ,os AS (
        SELECT
            flag, 
            sign,
            x.offs
        FROM
            j
            JOIN LATERAL
            (
                VALUES
                ('ITEM',1,null),
                ('OFFSET',-1,j.jb->'header'->>'offset')
            ) x (flag, sign, offs) ON TRUE
    )


------------do the cross join against all the item elements-------------------

,build AS (
SELECT
    array['item',rn::text]::text jpath
    ,COALESCE(os.offs,ae.e->>'account') acct
    ,(ae.e->>'amt')::numeric * os.sign amount
FROM
    j
    LEFT JOIN LATERAL JSONB_ARRAY_ELEMENTS(J.JB->'item') WITH ORDINALITY ae(e,rn) ON TRUE
    CROSS JOIN os
ORDER BY
    ae.rn ASC,
    os.flag ASC
)

-------------re-aggregate the items into a single array point called 'gl'---------------

,agg AS (
SELECT
    jsonb_build_object('gl',jsonb_agg(row_to_json(b))) gl
FROM
    build b
)

------------take the new 'gl' with array key-value pair and combine it with the original---------------

SELECT
    jsonb_pretty(agg.gl||j.jb)
INTO
    _j
FROM
    agg
    CROSS JOIN j;

RETURN _j;
    
END
$_$;


SET search_path = public, pg_catalog;

--
-- Name: jsonb_extract(jsonb, text[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION jsonb_extract(rec jsonb, key_list text[]) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
	t text[];
	j jsonb := '{}'::jsonb;
	
BEGIN
	FOREACH t SLICE 1 IN ARRAY key_list LOOP
		--RAISE NOTICE '%', t;
		--RAISE NOTICE '%', t[1];
		j := j || jsonb_build_object(t[1],rec#>t);
	END LOOP;
	RETURN j;
END;
$$;


SET search_path = tps, pg_catalog;

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
    rec jsonb,
    post_stmp timestamp with time zone DEFAULT now()
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
    parse jsonb,
    map jsonb,
    allj jsonb
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
-- Name: trans_allj; Type: INDEX; Schema: tps; Owner: -
--

CREATE INDEX trans_allj ON trans USING gin (allj);


--
-- Name: trans_rec; Type: INDEX; Schema: tps; Owner: -
--

CREATE INDEX trans_rec ON trans USING gin (rec);


--
-- Name: trans_srce; Type: INDEX; Schema: tps; Owner: -
--

CREATE INDEX trans_srce ON trans USING btree (srce);


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

