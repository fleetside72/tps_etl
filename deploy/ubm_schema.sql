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
-- Name: tps; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA tps;


--
-- Name: SCHEMA tps; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA tps IS 'third party source';


SET search_path = tps, pg_catalog;

--
-- Name: DCARD; Type: TYPE; Schema: tps; Owner: -
--

CREATE TYPE "DCARD" AS (
	"Trans. Date" date,
	"Post Date" date,
	"Description" text,
	"Amount" numeric,
	"Category" text
);


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
-- Name: jsonb_extract(jsonb, text[]); Type: FUNCTION; Schema: tps; Owner: -
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


--
-- Name: srce_import(text, text); Type: FUNCTION; Schema: tps; Owner: -
--

CREATE FUNCTION srce_import(_path text, _srce text) RETURNS jsonb
    LANGUAGE plpgsql
    AS $_$
DECLARE _t text;
DECLARE _c text;
DECLARE _log_info jsonb;
DECLARE _log_id text;
DECLARE _cnt numeric;
DECLARE _message jsonb;
_MESSAGE_TEXT text;
_PG_EXCEPTION_DETAIL text;
_PG_EXCEPTION_HINT text;

BEGIN

    --_path := 'C:\users\fleet\downloads\discover-recentactivity-20171031.csv';
    --_srce := 'DCARD';

----------------------------------------------------test if source exists----------------------------------------------------------------------------------

    SELECT
        COUNT(*)
    INTO
        _cnt
    FROM
        tps.srce    
    WHERE
        srce = _srce;

    IF _cnt = 0 THEN
        _message:= 
        format(
            $$
                {
                    "status":"fail",
                    "message":"source %L does not exists"
                }
            $$,
            _srce
        )::jsonb;
        RETURN _message;
    END IF;
----------------------------------------------------build the column list of the temp table----------------------------------------------------------------

	SELECT
        string_agg(quote_ident(prs.key)||' '||prs.type,','),
        string_agg(quote_ident(prs.key),',')
    INTO
    	_t, 
        _c
    FROM 
        tps.srce
        --unwrap the schema definition array
        LEFT JOIN LATERAL jsonb_populate_recordset(null::tps.srce_defn_schema, defn->'schema') prs ON TRUE
    WHERE   
        srce = _srce
    GROUP BY
        srce;
        
----------------------------------------------------add create table verbage in front of column list--------------------------------------------------------

    _t := format('CREATE TEMP TABLE csv_i (%s, id SERIAL)', _t);
    --RAISE NOTICE '%', _t;
    --RAISE NOTICE '%', _c;

    DROP TABLE IF EXISTS csv_i;
    
    EXECUTE _t;

----------------------------------------------------do the insert-------------------------------------------------------------------------------------------

    --the column list needs to be dynamic forcing this whole line to be dynamic
    _t := format('COPY csv_i (%s) FROM %L WITH (HEADER TRUE,DELIMITER '','', FORMAT CSV, ENCODING ''SQL_ASCII'',QUOTE ''"'');',_c,_path);

    --RAISE NOTICE '%', _t;

    BEGIN
        EXECUTE _t;
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS 
            _MESSAGE_TEXT = MESSAGE_TEXT,
            _PG_EXCEPTION_DETAIL = PG_EXCEPTION_DETAIL,
            _PG_EXCEPTION_HINT = PG_EXCEPTION_HINT;
        _message:= 
        ($$
            {
                "status":"fail",
                "message":"error importing data"
            }
        $$::jsonb)
        ||jsonb_build_object('message_text',_MESSAGE_TEXT)
        ||jsonb_build_object('pg_exception_detail',_PG_EXCEPTION_DETAIL);
        return _message;
    END;

    WITH 

    -------------extract the limiter fields to one row per source----------------------------------

    ext AS (
    SELECT 
        srce
        ,defn->'unique_constraint'->>'fields'
        ,ARRAY(SELECT ae.e::text[] FROM jsonb_array_elements_text(defn->'unique_constraint'->'fields') ae(e)) text_array
    FROM
        tps.srce
    WHERE
        srce = _srce
        --add where clause for targeted source
    )

    -------------for each imported row in the COPY table, genereate the json rec, and a column for the json key specified in the srce.defn-----------

    ,pending_list AS (
        SELECT
            tps.jsonb_extract(
                    row_to_json(i)::jsonb
                    ,ext.text_array
            ) json_key,
            row_to_json(i)::JSONB rec,
            srce,
            --ae.rn,
            id
        FROM
            csv_i i
            INNER JOIN ext ON
                ext.srce = _srce
        ORDER BY    
            id ASC
    )

    -----------create a unique list of keys from staged rows------------------------------------------------------------------------------------------

    , pending_keys AS (
        SELECT DISTINCT
            json_key
        FROM 
            pending_list
    )

    -----------list of keys already loaded to tps-----------------------------------------------------------------------------------------------------

    , matched_keys AS (
        SELECT DISTINCT
            k.json_key
        FROM
            pending_keys k
            INNER JOIN tps.trans t ON
                t.rec @> k.json_key
    )

    -----------return unique keys that are not already in tps.trans-----------------------------------------------------------------------------------

    , unmatched_keys AS (
    SELECT
        json_key
    FROM
        pending_keys

    EXCEPT

    SELECT
        json_key
    FROM
        matched_keys
    )

    -----------insert pending rows that have key with no trans match-----------------------------------------------------------------------------------
    --need to look into mapping the transactions prior to loading

    , inserted AS (
        INSERT INTO
            tps.trans (srce, rec)
        SELECT
            pl.srce
            ,pl.rec
        FROM 
            pending_list pl
            INNER JOIN unmatched_keys u ON
                u.json_key = pl.json_key
        ORDER BY
            pl.id ASC
        ----this conflict is only if an exact duplicate rec json happens, which will be rejected
        ----therefore, records may not be inserted due to ay matches with certain json fields, or if the entire json is a duplicate, reason is not specified
        RETURNING *
    )

    --------summarize records not inserted-------------------+------------------------------------------------------------------------------------------------

    , logged AS (
    INSERT INTO
        tps.trans_log (info)
    SELECT
        JSONB_BUILD_OBJECT('time_stamp',CURRENT_TIMESTAMP)
        ||JSONB_BUILD_OBJECT('srce',_srce)
        ||JSONB_BUILD_OBJECT('path',_path)
        ||JSONB_BUILD_OBJECT('not_inserted',
            (
                SELECT 
                    jsonb_agg(json_key)
                FROM
                    matched_keys
            )
        )
        ||JSONB_BUILD_OBJECT('inserted',
            (
                SELECT 
                    jsonb_agg(json_key)
                FROM
                    unmatched_keys
            )
        )
    RETURNING *
    )

    SELECT
        id
        ,info
    INTO
        _log_id
        ,_log_info
    FROM
        logged;

    --RAISE NOTICE 'import logged under id# %, info: %', _log_id, _log_info;

    _message:= 
    (
        format(
        $$
            {
            "status":"complete",
            "message":"import of %L for source %L complete"
            }
        $$, _path, _srce)::jsonb
    )||jsonb_build_object('details',_log_info);

    RETURN _message;
END
$_$;


--
-- Name: srce_map_def_set(text, text, jsonb, integer); Type: FUNCTION; Schema: tps; Owner: -
--

CREATE FUNCTION srce_map_def_set(_srce text, _map text, _defn jsonb, _seq integer) RETURNS jsonb
    LANGUAGE plpgsql
    AS $_$

DECLARE
    _message jsonb;
    _MESSAGE_TEXT text;
    _PG_EXCEPTION_DETAIL text;
    _PG_EXCEPTION_HINT text;

BEGIN

    BEGIN

        INSERT INTO
            tps.map_rm
        SELECT
            _srce
            ,_map
            ,_defn
            ,_seq
        ON CONFLICT ON CONSTRAINT map_rm_pk DO UPDATE SET
            srce = _srce
            ,target = _map
            ,regex = _defn
            ,seq = _seq;

    EXCEPTION WHEN OTHERS THEN

        GET STACKED DIAGNOSTICS 
                _MESSAGE_TEXT = MESSAGE_TEXT,
                _PG_EXCEPTION_DETAIL = PG_EXCEPTION_DETAIL,
                _PG_EXCEPTION_HINT = PG_EXCEPTION_HINT;
            _message:= 
            ($$
                {
                    "status":"fail",
                    "message":"error setting definition"
                }
            $$::jsonb)
            ||jsonb_build_object('message_text',_MESSAGE_TEXT)
            ||jsonb_build_object('pg_exception_detail',_PG_EXCEPTION_DETAIL);
            return _message;
    END;

    _message:= jsonb_build_object('status','complete','message','definition has been set');
    return _message;

END;
$_$;


--
-- Name: srce_map_overwrite(text); Type: FUNCTION; Schema: tps; Owner: -
--

CREATE FUNCTION srce_map_overwrite(_srce text) RETURNS jsonb
    LANGUAGE plpgsql
    AS $_$
DECLARE
    _message jsonb;
    _MESSAGE_TEXT text;
    _PG_EXCEPTION_DETAIL text;
    _PG_EXCEPTION_HINT text;

BEGIN
    WITH
    --------------------apply regex operations to transactions-----------------------------------------------------------------------------------

    rx AS (
    SELECT 
        t.srce,
        t.id,
        t.rec,
        m.target,
        m.seq,
        regex->>'function' regex_function,
        e.v ->> 'field' result_key_name,
        e.v ->> 'key' target_json_path,
        e.v ->> 'flag' regex_options_flag,
        e.v->>'map' map_intention,
        e.v->>'retain' retain_result,
        e.v->>'regex' regex_expression,
        e.rn target_item_number,
        COALESCE(mt.rn,rp.rn,1) result_number,
        mt.mt rx_match,
        rp.rp rx_replace,
        CASE e.v->>'map'
            WHEN 'y' THEN
                e.v->>'field'
            ELSE
                null
        END map_key,
        CASE e.v->>'map'
            WHEN 'y' THEN
                CASE regex->>'function'
                    WHEN 'extract' THEN
                        CASE WHEN array_upper(mt.mt,1)=1 
                            THEN to_json(mt.mt[1])
                            ELSE array_to_json(mt.mt)
                        END::jsonb
                    WHEN 'replace' THEN
                        to_jsonb(rp.rp)
                    ELSE
                        '{}'::jsonb
                END
            ELSE
                NULL
        END map_val,
        CASE e.v->>'retain'
            WHEN 'y' THEN
                e.v->>'field'
            ELSE
                NULL
        END retain_key,
        CASE e.v->>'retain'
            WHEN 'y' THEN
                CASE regex->>'function'
                    WHEN 'extract' THEN
                        CASE WHEN array_upper(mt.mt,1)=1 
                            THEN to_json(trim(mt.mt[1]))
                            ELSE array_to_json(mt.mt)
                        END::jsonb
                    WHEN 'replace' THEN
                        to_jsonb(rtrim(rp.rp))
                    ELSE
                        '{}'::jsonb
                END
            ELSE
                NULL
        END retain_val
    FROM 
        tps.map_rm m
        LEFT JOIN LATERAL jsonb_array_elements(m.regex->'where') w(v) ON TRUE
        INNER JOIN tps.trans t ON 
            t.srce = m.srce AND
            t.rec @> w.v
        LEFT JOIN LATERAL jsonb_array_elements(m.regex->'defn') WITH ORDINALITY e(v, rn) ON true
        LEFT JOIN LATERAL regexp_matches(t.rec #>> ((e.v ->> 'key')::text[]), e.v ->> 'regex'::text,COALESCE(e.v ->> 'flag','')) WITH ORDINALITY mt(mt, rn) ON
            m.regex->>'function' = 'extract'
        LEFT JOIN LATERAL regexp_replace(t.rec #>> ((e.v ->> 'key')::text[]), e.v ->> 'regex'::text, e.v ->> 'replace'::text,e.v ->> 'flag') WITH ORDINALITY rp(rp, rn) ON
            m.regex->>'function' = 'replace'
    WHERE
        --t.allj IS NULL
        t.srce = _srce
        --rec @> '{"Transaction":"ACH Credits","Transaction":"ACH Debits"}'
        --rec @> '{"Description":"CHECK 93013270 086129935"}'::jsonb
    ORDER BY 
        t.id DESC,
        m.target,
        e.rn,
        COALESCE(mt.rn,rp.rn,1)
    )

    --SELECT count(*) FROM rx LIMIT 100


    , agg_to_target_items AS (
    SELECT 
        srce
        ,id
        ,target
        ,seq
        ,map_intention
        ,regex_function
        ,target_item_number
        ,result_key_name
        ,target_json_path
        ,CASE WHEN map_key IS NULL 
            THEN    
                NULL 
            ELSE 
                jsonb_build_object(
                    map_key,
                    CASE WHEN max(result_number) = 1
                        THEN
                            jsonb_agg(map_val ORDER BY result_number) -> 0
                        ELSE
                            jsonb_agg(map_val ORDER BY result_number)
                    END
                ) 
        END map_val
        ,CASE WHEN retain_key IS NULL 
            THEN 
                NULL 
            ELSE 
                jsonb_build_object(
                    retain_key,
                    CASE WHEN max(result_number) = 1
                        THEN
                            jsonb_agg(retain_val ORDER BY result_number) -> 0
                        ELSE
                            jsonb_agg(retain_val ORDER BY result_number)
                    END
                ) 
        END retain_val
    FROM 
        rx
    GROUP BY
        srce
        ,id
        ,target
        ,seq
        ,map_intention
        ,regex_function
        ,target_item_number
        ,result_key_name
        ,target_json_path
        ,map_key
        ,retain_key
    )

    --SELECT * FROM agg_to_target_items LIMIT 100


    , agg_to_target AS (
    SELECT
        srce
        ,id
        ,target
        ,seq
        ,map_intention
        ,tps.jsonb_concat_obj(COALESCE(map_val,'{}'::JSONB)) map_val
        ,jsonb_strip_nulls(tps.jsonb_concat_obj(COALESCE(retain_val,'{}'::JSONB))) retain_val
    FROM
        agg_to_target_items
    GROUP BY
        srce
        ,id
        ,target
        ,seq
        ,map_intention
    ORDER BY
        id
    )


    --SELECT * FROM agg_to_target


    , link_map AS (
    SELECT
        a.srce
        ,a.id
        ,a.target
        ,a.seq
        ,a.map_intention
        ,a.map_val
        ,a.retain_val retain_value
        ,v.map
    FROM
        agg_to_target a
        LEFT OUTER JOIN tps.map_rv v ON
            v.srce = a.srce AND
            v.target = a.target AND
            v.retval = a.map_val
    )

    --SELECT * FROM link_map

    , agg_to_id AS (
    SELECT
        srce
        ,id
        ,tps.jsonb_concat_obj(COALESCE(retain_value,'{}'::jsonb) ORDER BY seq DESC) retain_val
        ,tps.jsonb_concat_obj(COALESCE(map,'{}'::jsonb)) map
    FROM
        link_map
    GROUP BY
        srce
        ,id
    )

    --SELECT agg_to_id.srce, agg_to_id.id, jsonb_pretty(agg_to_id.retain_val) , jsonb_pretty(agg_to_id.map) FROM agg_to_id ORDER BY id desc LIMIT 100



    UPDATE
        tps.trans t
    SET
        map = o.map,
        parse = o.retain_val,
        allj = t.rec||o.map||o.retain_val
    FROM
        agg_to_id o
    WHERE
        o.id = t.id;

    _message:= jsonb_build_object('status','complete');
    RETURN _message;

EXCEPTION WHEN OTHERS THEN

    GET STACKED DIAGNOSTICS 
            _MESSAGE_TEXT = MESSAGE_TEXT,
            _PG_EXCEPTION_DETAIL = PG_EXCEPTION_DETAIL,
            _PG_EXCEPTION_HINT = PG_EXCEPTION_HINT;
    _message:= 
        ($$
            {
                "status":"fail",
                "message":"error setting map value"
            }
        $$::jsonb)
        ||jsonb_build_object('message_text',_MESSAGE_TEXT)
        ||jsonb_build_object('pg_exception_detail',_PG_EXCEPTION_DETAIL);

    RETURN _message;
END;
$_$;


--
-- Name: srce_map_val_set(text, text, jsonb, jsonb); Type: FUNCTION; Schema: tps; Owner: -
--

CREATE FUNCTION srce_map_val_set(_srce text, _target text, _ret jsonb, _map jsonb) RETURNS jsonb
    LANGUAGE plpgsql
    AS $_$

DECLARE
    _message jsonb;
    _MESSAGE_TEXT text;
    _PG_EXCEPTION_DETAIL text;
    _PG_EXCEPTION_HINT text;

BEGIN

    INSERT INTO
        tps.map_rv
    SELECT
        _srce
        ,_target
        ,_ret
        ,_map
    ON CONFLICT ON CONSTRAINT map_rv_pk DO UPDATE SET
        srce = _srce
        ,target = _target
        ,retval = _ret
        ,map = _map;

    _message:= jsonb_build_object('status','complete');
    RETURN _message;

EXCEPTION WHEN OTHERS THEN

    GET STACKED DIAGNOSTICS 
            _MESSAGE_TEXT = MESSAGE_TEXT,
            _PG_EXCEPTION_DETAIL = PG_EXCEPTION_DETAIL,
            _PG_EXCEPTION_HINT = PG_EXCEPTION_HINT;
    _message:= 
        ($$
            {
                "status":"fail",
                "message":"error setting map value"
            }
        $$::jsonb)
        ||jsonb_build_object('message_text',_MESSAGE_TEXT)
        ||jsonb_build_object('pg_exception_detail',_PG_EXCEPTION_DETAIL);

        RETURN _message;

END
$_$;


--
-- Name: srce_set(text, jsonb); Type: FUNCTION; Schema: tps; Owner: -
--

CREATE FUNCTION srce_set(_name text, _defn jsonb) RETURNS jsonb
    LANGUAGE plpgsql
    AS $_$

DECLARE
_cnt int;
_conflict BOOLEAN;
_message jsonb;
_sql text;

BEGIN

/*
1. determine if insert or update
2. if update, determine if conflicts exists
3. do merge
*/

    -------check for transctions already existing under this source-----------
    SELECT
        COUNT(*)
    INTO
        _cnt
    FROM
        tps.trans
    WHERE
        srce = _name;

    -------set a message------------------------------------------------------
    IF _cnt > 0 THEN
        _conflict = TRUE;
        --get out of the function somehow
        _message = 
        $$
                {
                    "message":"transactions already exist under source profile, cannot change the definition"
                    ,"status":"error"
                }
        $$::jsonb;
        return _message;
    END IF;

    /*-------------------------------------------------------
    schema validation
    ---------------------------------------------------------*/
    
    -------------------insert definition----------------------------------------
    INSERT INTO
        tps.srce
    SELECT
        _name, _defn
    ON CONFLICT ON CONSTRAINT srce_pkey DO UPDATE
        SET
            defn = _defn;

    ------------------drop existing type-----------------------------------------

    EXECUTE format('DROP TYPE IF EXISTS tps.%I',_name);

    ------------------create new type--------------------------------------------

    SELECT
        string_agg(quote_ident(prs.key)||' '||prs.type,',')
    INTO
        _sql
    FROM 
        tps.srce
        --unwrap the schema definition array
        LEFT JOIN LATERAL jsonb_populate_recordset(null::tps.srce_defn_schema, defn->'schema') prs ON TRUE
    WHERE   
        srce = _name
    GROUP BY
        srce;

    RAISE NOTICE 'CREATE TYPE tps.% AS (%)',_name,_sql;

    EXECUTE format('CREATE TYPE tps.%I AS (%s)',_name,_sql);

    ----------------set message-----------------------------------------------------
    
    _message = 
        $$
                {
                    "message":"definition set"
                    ,"status":"success"
                }
        $$::jsonb;
    return _message;

END;
$_$;


--
-- Name: jsonb_concat_obj(jsonb); Type: AGGREGATE; Schema: tps; Owner: -
--

CREATE AGGREGATE jsonb_concat_obj(jsonb) (
    SFUNC = jsonb_concat,
    STYPE = jsonb,
    INITCOND = '{}'
);


SET default_tablespace = '';

SET default_with_oids = false;

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
-- Name: TABLE map_rm; Type: COMMENT; Schema: tps; Owner: -
--

COMMENT ON TABLE map_rm IS 'regex instructions';


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
-- Name: TABLE map_rv; Type: COMMENT; Schema: tps; Owner: -
--

COMMENT ON TABLE map_rv IS 'map return value assignemnt';


--
-- Name: srce; Type: TABLE; Schema: tps; Owner: -
--

CREATE TABLE srce (
    srce text NOT NULL,
    defn jsonb
);


--
-- Name: TABLE srce; Type: COMMENT; Schema: tps; Owner: -
--

COMMENT ON TABLE srce IS 'source master listing and definition';


--
-- Name: trans; Type: TABLE; Schema: tps; Owner: -
--

CREATE TABLE trans (
    id integer NOT NULL,
    srce text,
    rec jsonb,
    parse jsonb,
    map jsonb,
    allj jsonb,
    logid bigint
);


--
-- Name: TABLE trans; Type: COMMENT; Schema: tps; Owner: -
--

COMMENT ON TABLE trans IS 'source records';


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
-- Name: TABLE trans_log; Type: COMMENT; Schema: tps; Owner: -
--

COMMENT ON TABLE trans_log IS 'import event information';


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

