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

SET search_path = evt, pg_catalog;

--
-- Data for Name: log; Type: TABLE DATA; Schema: evt; Owner: -
--



SET search_path = tps, pg_catalog;

--
-- Data for Name: srce; Type: TABLE DATA; Schema: tps; Owner: -
--

INSERT INTO srce (srce, defn) VALUES ('PNCL', '{"name": "PNCL", "type": "csv", "descr": "PNC Loan Ledger", "schema": [{"key": "Schedule#", "type": "text"}, {"key": "PostDate", "type": "date"}, {"key": "Assn#", "type": "text"}, {"key": "Coll#", "type": "text"}, {"key": "AdvanceRate", "type": "numeric"}, {"key": "Sales", "type": "numeric"}, {"key": "Credits & Adjustments", "type": "numeric"}, {"key": "Gross Collections", "type": "numeric"}, {"key": "CollateralBalance", "type": "numeric"}, {"key": "MaxEligible", "type": "numeric"}, {"key": "Ineligible Amount", "type": "numeric"}, {"key": "Reserve Amount", "type": "numeric"}], "unique_constraint": {"type": "key", "fields": ["{PostDate}", "{Schedule#}"]}}');
INSERT INTO srce (srce, defn) VALUES ('ADPRP', '{"name": "ADPRP", "type": "csv", "descr": "ADP Detail Report", "schema": [{"key": "batch", "type": "text"}, {"key": "week", "type": "text"}, {"key": "period_end", "type": "text"}, {"key": "pay_date", "type": "text"}, {"key": "adp_comp", "type": "text"}, {"key": "hours_reg", "type": "numeric"}, {"key": "hours_ot", "type": "numeric"}, {"key": "adp_dep_home", "type": "text"}, {"key": "adp_dep_worked", "type": "text"}, {"key": "adp_dep", "type": "text"}, {"key": "gl_dep", "type": "text"}, {"key": "checkn", "type": "text"}, {"key": "employee", "type": "text"}, {"key": "title", "type": "text"}, {"key": "prim_offset", "type": "text"}, {"key": "cms_tb", "type": "text"}, {"key": "cms_acct", "type": "text"}, {"key": "gl_descr", "type": "text"}, {"key": "amount", "type": "numeric"}], "unique_constraints": {"type": "key", "fields": ["{pay_date}", "{adp_comp}"]}}');
INSERT INTO srce (srce, defn) VALUES ('PNCC', '{"name": "PNCC", "type": "csv", "descr": "PNC Cash Accounts", "schema": [{"key": "AsOfDate", "type": "date"}, {"key": "BankId", "type": "text"}, {"key": "AccountNumber", "type": "text"}, {"key": "AccountName", "type": "text"}, {"key": "BaiControl", "type": "text"}, {"key": "Currency", "type": "text"}, {"key": "Transaction", "type": "text"}, {"key": "Reference", "type": "text"}, {"key": "Amount", "type": "text"}, {"key": "Description", "type": "text"}, {"key": "AdditionalRemittance", "type": "text"}], "unique_constraint": {"type": "range", "fields": ["{AsOfDate}"]}}');
INSERT INTO srce (srce, defn) VALUES ('PNCO', '{"name": "PNCO", "type": "csv", "descr": "PNC Loan Ledger", "schema": [{"key": "Loan#", "type": "text"}, {"key": "Post Date", "type": "date"}, {"key": "Effective Date", "type": "date"}, {"key": "Reference #", "type": "text"}, {"key": "Description", "type": "text"}, {"key": "Advances", "type": "numeric"}, {"key": "Adjustments", "type": "numeric"}, {"key": "Payments", "type": "numeric"}, {"key": "Loan Balance", "type": "numeric"}, {"key": "Assn#", "type": "text"}, {"key": "Coll#", "type": "text"}], "unique_constraint": {"type": "range", "fields": ["{Post Date}", "{Effective Date}", "{Loan#}"]}}');


SET search_path = evt, pg_catalog;

--
-- Name: log_id_seq; Type: SEQUENCE SET; Schema: evt; Owner: -
--

SELECT pg_catalog.setval('log_id_seq', 1, false);


SET search_path = tps, pg_catalog;

--
-- Name: trans_id_seq; Type: SEQUENCE SET; Schema: tps; Owner: -
--

SELECT pg_catalog.setval('trans_id_seq', 1543110, true);


--
-- PostgreSQL database dump complete
--

