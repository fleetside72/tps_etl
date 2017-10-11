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

SET search_path = evt, pg_catalog;

--
-- Data for Name: log; Type: TABLE DATA; Schema: evt; Owner: -
--

INSERT INTO log (id, rec) VALUES (1, '{"date": "2017-08-20", "item": [{"item": "Green Chili", "amount": 1.49, "account": "food"}, {"item": "Black Beans", "amount": 1.6, "account": "food"}, {"item": "Distilled Water", "amount": 7.12, "account": "food"}, {"item": "Fruit Preservative", "amount": 3.99, "account": "food"}, {"item": "Watch Battery", "amount": 3.79, "account": "stuff"}, {"item": "Sales Tax", "amount": "0.26", "account": "taxes"}, {"item": "Green Chili", "amount": -1.49, "account": "dcard"}, {"item": "Black Beans", "amount": -1.6, "account": "dcard"}, {"item": "Distilled Water", "amount": -7.12, "account": "dcard"}, {"item": "Fruit Preservative", "amount": -3.99, "account": "dcard"}, {"item": "Watch Battery", "amount": -3.79, "account": "dcard"}, {"item": "Sales Tax", "amount": -0.26, "account": "dcard"}], "vendor": "Drug Mart", "instrument": "Discover Card"}');


SET search_path = tps, pg_catalog;

--
-- Data for Name: srce; Type: TABLE DATA; Schema: tps; Owner: -
--

INSERT INTO srce (srce, defn) VALUES ('PNCC', '{"name": "PNCC", "type": "csv", "schema": [{"key": "AsOfDate", "type": "date"}, {"key": "BankId", "type": "text"}, {"key": "AccountNumber", "type": "text"}, {"key": "AccountName", "type": "text"}, {"key": "BaiControl", "type": "text"}, {"key": "Currency", "type": "text"}, {"key": "Transaction", "type": "text"}, {"key": "Reference", "type": "text"}, {"key": "Amount", "type": "text"}, {"key": "Description", "type": "text"}, {"key": "AdditionalRemittance", "type": "text"}], "unique_constraint": {"type": "range", "fields": ["{AsOfDate}"]}}');


SET search_path = evt, pg_catalog;

--
-- Name: log_id_seq; Type: SEQUENCE SET; Schema: evt; Owner: -
--

SELECT pg_catalog.setval('log_id_seq', 1, true);


--
-- PostgreSQL database dump complete
--

