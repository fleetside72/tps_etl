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

INSERT INTO srce (srce, defn) VALUES ('PNCC', '{"name": "PNCC", "type": "csv", "descr": "PNC Cash Accounts", "schema": [{"key": "AsOfDate", "type": "date"}, {"key": "BankId", "type": "text"}, {"key": "AccountNumber", "type": "text"}, {"key": "AccountName", "type": "text"}, {"key": "BaiControl", "type": "text"}, {"key": "Currency", "type": "text"}, {"key": "Transaction", "type": "text"}, {"key": "Reference", "type": "text"}, {"key": "Amount", "type": "text"}, {"key": "Description", "type": "text"}, {"key": "AdditionalRemittance", "type": "text"}], "unique_constraint": {"type": "range", "fields": ["{AsOfDate}"]}}');
INSERT INTO srce (srce, defn) VALUES ('PNCO', '{"name": "PNCO", "type": "csv", "descr": "PNC Loan Ledger", "schema": [{"key": "Loan#", "type": "text"}, {"key": "Post Date", "type": "date"}, {"key": "Effective Date", "type": "date"}, {"key": "Reference #", "type": "text"}, {"key": "Description", "type": "text"}, {"key": "Advances", "type": "numeric"}, {"key": "Adjustments", "type": "numeric"}, {"key": "Payments", "type": "numeric"}, {"key": "Loan Balance", "type": "numeric"}], "unique_constraint": {"type": "range", "fields": ["{Post Date}", "{Effective Date}", "{Loan#}"]}}');
INSERT INTO srce (srce, defn) VALUES ('PNCL', '{"name": "PNCL", "type": "csv", "descr": "PNC Loan Ledger", "schema": [{"key": "Schedule#", "type": "text"}, {"key": "PostDate", "type": "date"}, {"key": "Assn#", "type": "text"}, {"key": "Coll#", "type": "text"}, {"key": "AdvanceRate", "type": "numeric"}, {"key": "Sales", "type": "numeric"}, {"key": "Credits & Adjustments", "type": "numeric"}, {"key": "Gross Collections", "type": "numeric"}, {"key": "CollateralBalance", "type": "numeric"}, {"key": "MaxEligible", "type": "numeric"}, {"key": "Ineligible Amount", "type": "numeric"}, {"key": "Reserve Amount", "type": "numeric"}], "unique_constraint": {"type": "key", "fields": ["{PostDate}", "{Schedule#}"]}}');
INSERT INTO srce (srce, defn) VALUES ('ADPRP', '{"name": "ADPRP", "type": "csv", "descr": "ADP Detail Report", "schema": [{"key": "batch", "type": "text"}, {"key": "week", "type": "text"}, {"key": "period_end", "type": "text"}, {"key": "pay_date", "type": "text"}, {"key": "adp_comp", "type": "text"}, {"key": "hours_reg", "type": "numeric"}, {"key": "hours_ot", "type": "numeric"}, {"key": "adp_dep_home", "type": "text"}, {"key": "adp_dep_worked", "type": "text"}, {"key": "adp_dep", "type": "text"}, {"key": "gl_dep", "type": "text"}, {"key": "checkn", "type": "text"}, {"key": "employee", "type": "text"}, {"key": "title", "type": "text"}, {"key": "prim_offset", "type": "text"}, {"key": "cms_tb", "type": "text"}, {"key": "cms_acct", "type": "text"}, {"key": "gl_descr", "type": "text"}, {"key": "amount", "type": "numeric"}], "unique_constraint": {"type": "key", "fields": ["{pay_date}", "{adp_comp}"]}}');


--
-- Data for Name: map_rm; Type: TABLE DATA; Schema: tps; Owner: -
--

INSERT INTO map_rm (srce, target, regex, seq) VALUES ('PNCC', 'Strip Amount Commas', '{"defn": [{"key": "{Amount}", "map": "n", "flag": "g", "field": "amount", "regex": ",", "retain": "y", "replace": ""}], "name": "Strip Amount Commas", "where": [{}], "function": "replace", "description": "the Amount field come from PNC with commas embeded so it cannot be cast to numeric"}', 1);
INSERT INTO map_rm (srce, target, regex, seq) VALUES ('PNCC', 'Trans Type', '{"defn": [{"key": "{AccountName}", "map": "y", "field": "acctn", "regex": "(.*)", "retain": "n"}, {"key": "{Transaction}", "map": "y", "field": "trans", "regex": "(.*)", "retain": "n"}, {"key": "{Description}", "map": "y", "field": "ini", "regex": "([\\w].*?)(?=$| -|\\s[0-9].*?|\\s[\\w/]+?:)", "retain": "y"}], "name": "Trans Type", "where": [{}], "function": "extract", "description": "extract intial description in conjunction with account name and transaction type for mapping"}', 1);
INSERT INTO map_rm (srce, target, regex, seq) VALUES ('PNCC', 'Currency', '{"defn": [{"key": "{Description}", "map": "y", "field": "ini", "regex": "([\\w].*?)(?=$| -|\\s[0-9].*?|\\s[\\w/]+?:)", "retain": "y"}, {"key": "{Description}", "map": "y", "field": "curr1", "regex": ".*(DEBIT|CREDIT).*(USD|CAD).*(?=DEBIT|CREDIT).*(?=USD|CAD).*", "retain": "y"}, {"key": "{Description}", "map": "y", "field": "curr2", "regex": ".*(?=DEBIT|CREDIT).*(?=USD|CAD).*(DEBIT|CREDIT).*(USD|CAD).*", "retain": "y"}], "name": "Currency", "where": [{"Transaction": "Miscellaneous Credits"}, {"Transaction": "Miscellaneous Debits"}], "function": "extract", "description": "pull out currency indicators from description of misc items and map"}', 2);
INSERT INTO map_rm (srce, target, regex, seq) VALUES ('PNCC', 'Check Number', '{"defn": [{"key": "{Description}", "map": "n", "field": "checkn", "regex": "[^0-9]*([0-9]*)\\s|$", "retain": "y"}], "where": [{"Transaction": "Checks Paid"}], "function": "extract"}', 2);
INSERT INTO map_rm (srce, target, regex, seq) VALUES ('PNCC', 'Parse ACH', '{"defn": [{"key": "{Description}", "map": "n", "flag": "", "field": "Comp Name", "regex": "Comp Name:(.+?)(?=\\d{6} Com|SEC:|Cust ID:|Desc:|Comp Name:|Comp ID:|Batch Discr:|Cust Name:|Addenda:|SETT:|Date:|Time:|$)", "retain": "y"}, {"key": "{Description}", "map": "n", "flag": "", "field": "Cust ID", "regex": "Cust ID:(.+?)(?=SEC:|Cust ID:|Desc:|Comp Name:|Comp ID:|Batch Discr:|Cust Name:|Addenda:|SETT:|Date:|Time:|$)", "retain": "y"}, {"key": "{Description}", "map": "n", "flag": "", "field": "Desc", "regex": "Desc:(.+?)(?=SEC:|Cust ID:|Desc:|Comp Name:|Comp ID:|Batch Discr:|Cust Name:|Addenda:|SETT:|Date:|Time:|$)", "retain": "y"}, {"key": "{Description}", "map": "n", "flag": "", "field": "Cust Name", "regex": "Cust Name:(.+?)(?=SEC:|Cust ID:|Desc:|Comp Name:|Comp ID:|Batch Discr:|Cust Name:|Addenda:|SETT:|Date:|Time:|$)", "retain": "y"}, {"key": "{Description}", "map": "n", "flag": "", "field": "Batch Discr", "regex": "Batch Discr:(.+?)(?=SEC:|Cust ID:|Desc:|Comp Name:|Comp ID:|Batch Discr:|Cust Name:|Addenda:|SETT:|Date:|Time:|$)", "retain": "y"}, {"key": "{Description}", "map": "n", "flag": "", "field": "Comp ID", "regex": "Comp ID:(.+?)(?=SEC:|Cust ID:|Desc:|Comp Name:|Comp ID:|Batch Discr:|Cust Name:|Addenda:|SETT:|Date:|Time:|$)", "retain": "y"}, {"key": "{Description}", "map": "n", "flag": "", "field": "Addenda", "regex": "Addenda:(.+?)(?=SEC:|Cust ID:|Desc:|Comp Name:|Comp ID:|Batch Discr:|Cust Name:|Addenda:|SETT:|Date:|Time:|$)", "retain": "y"}, {"key": "{Description}", "map": "n", "flag": "", "field": "SETT", "regex": "SETT:(.+?)(?=SEC:|Cust ID:|Desc:|Comp Name:|Comp ID:|Batch Discr:|Cust Name:|Addenda:|SETT:|Date:|Time:|$)", "retain": "y"}, {"key": "{Description}", "map": "n", "flag": "", "field": "Date", "regex": "Date:(.+?)(?=SEC:|Cust ID:|Desc:|Comp Name:|Comp ID:|Batch Discr:|Cust Name:|Addenda:|SETT:|Date:|Time:|$)", "retain": "y"}, {"key": "{Description}", "map": "n", "flag": "", "field": "Time", "regex": "Time:(.+?)(?=SEC:|Cust ID:|Desc:|Comp Name:|Comp ID:|Batch Discr:|Cust Name:|Addenda:|SETT:|Date:|Time:|$)", "retain": "y"}], "name": "Parse ACH", "where": [{"Transaction": "ACH Credits"}, {"Transaction": "ACH Debits"}], "function": "extract", "description": "parse select components of the description for ACH Credits Receieved"}', 2);
INSERT INTO map_rm (srce, target, regex, seq) VALUES ('PNCC', 'Parse Wires', '{"defn": [{"key": "{Description}", "map": "n", "flag": "g", "field": "dparse", "regex": "([A-Z]{3,}?:)(.*)(?=[A-Z]{3,}?:|$)", "retain": "y"}, {"key": "{Description}", "map": "n", "flag": "", "field": "beneficiary_components", "regex": "BENEFICIARY:(.*?)AC/(\\d*) (.*)(?=[A-Z]{3,}?:|$)", "retain": "y"}, {"key": "{Description}", "map": "n", "flag": "", "field": "originator_components", "regex": "ORIGINATOR:(.*?)AC/(\\d*) (.*)(?=[A-Z]{3,}?:|$)", "retain": "y"}, {"key": "{Description}", "map": "n", "flag": "", "field": "OBI", "regex": "OBI:(.*?)(?=[A-Z]{3,}?:|$)", "retain": "y"}, {"key": "{Description}", "map": "n", "flag": "", "field": "RFB", "regex": "RFB:(.*?)(?=[A-Z]{3,}?:|$)", "retain": "y"}, {"key": "{Description}", "map": "n", "flag": "", "field": "ABA", "regex": "ABA:(.*?)(?=[A-Z]{3,}?:|$)", "retain": "y"}, {"key": "{Description}", "map": "n", "flag": "", "field": "BBI", "regex": "BBI:(.*?)(?=[A-Z]{3,}?:|$)", "retain": "y"}, {"key": "{Description}", "map": "n", "flag": "", "field": "BENEBNK", "regex": "BENEBNK:(.*?)(?=[A-Z]{3,}?:|$)", "retain": "y"}, {"key": "{Description}", "map": "n", "flag": "", "field": "IBK", "regex": "IBK:(.*?)(?=[A-Z]{3,}?:|$)", "retain": "y"}, {"key": "{Description}", "map": "n", "flag": "", "field": "RATE", "regex": "RATE:(.*?)(?=[A-Z]{3,}?:|$)", "retain": "y"}, {"key": "{Description}", "map": "n", "flag": "", "field": "RECVBNK", "regex": "RECVBNK:(.*?)(?=[A-Z]{3,}?:|$)", "retain": "y"}], "name": "Parse Wires", "where": [{"Transaction": "Money Transfer DB - Wire"}, {"Transaction": "Money Transfer DB - Other"}, {"Transaction": "Money Transfer CR-Wire"}, {"Transaction": "Money Transfer CR-Other"}, {"Transaction": "Intl Money Transfer Debits"}, {"Transaction": "Intl Money Transfer Credits"}], "function": "extract", "description": "pull out whatever follows OBI in the description until atleast 3 capital letters followed by a colon are encountered"}', 2);


--
-- Data for Name: map_rv; Type: TABLE DATA; Schema: tps; Owner: -
--

INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "CANADA TAX", "acctn": "The HC Operating Company OPERA", "trans": "Detail Debit Adjustments"}', '{"sign": "-1", "party": "PNC", "ledger": "Manual", "reason": "Bank Fees", "trantype": "Disbursement"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "ACH DEBIT SETTLEMENT", "acctn": "The HC Operating Company OPERA", "trans": "ACH Debits"}', '{"sign": "-1", "ledger": "AP - ACH", "trantype": "Disbursement"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "RET DEP ITEM RTM", "acctn": "The HC Operating Company FBO P", "trans": "Deposited Items Returned"}', '{"sign": "-1", "ledger": "Manual", "reason": "Returned Deposit RTM", "trantype": "Collections"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "RET DEP ITEM STOP", "acctn": "The HC Operating Company FBO P", "trans": "Deposited Items Returned"}', '{"sign": "-1", "ledger": "Manual", "reason": "Returned Deposit STOP", "trantype": "Collections"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "CREDIT ADJUSTMENT", "acctn": "The HC Operating Company FBO P", "trans": "Detail Credit Adjustments"}', '{"sign": "1", "ledger": "AR - Collections", "trantype": "Collections"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "REFER TO MAKER OF CK RETURN CK", "acctn": "The HC Operating Company OPERA", "trans": "Detail Credit Adjustments"}', '{"sign": "1", "ledger": "Manual", "reason": "Returned Check", "trantype": "Disbursement"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "DEBIT ADJUSTMENT", "acctn": "The HC Operating Company PAYR", "trans": "Detail Debit Adjustments"}', '{"sign": "-1", "ledger": "Manual", "reason": "Payroll Adjustment", "trantype": "Disbursement"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "DEPOSIT", "acctn": "The HC Operating Company FBO P", "trans": "Detail Deposits"}', '{"sign": "1", "ledger": "AR - Collections", "trantype": "Collections"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "INTL WIRE OUT", "acctn": "The HC Operating Company OPERA", "trans": "Intl Money Transfer Debits"}', '{"sign": "-1", "ledger": "AP - Wire", "trantype": "Disbursement"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "INTL WIRES OUT", "acctn": "The HC Operating Company OPERA", "trans": "Intl Money Transfer Debits"}', '{"sign": "-1", "ledger": "AP - Wire", "trantype": "Disbursement"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "WHLS LBX DEP", "acctn": "The HC Operating Company FBO P", "trans": "Lockbox Deposits"}', '{"sign": "1", "ledger": "AR - Collections", "trantype": "Collections"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "WHLS LBX DEP932855", "acctn": "The HC Operating Company FBO P", "trans": "Lockbox Deposits"}', '{"sign": "1", "ledger": "AR - Collections", "trantype": "Collections"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "ADVANCE", "acctn": "The HC Operating Company OPERA", "trans": "Miscellaneous Credits"}', '{"sign": "1", "ledger": "Manual", "reason": "Revolver Advance", "trantype": "Revolver Borrow"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "DEPOSIT:", "acctn": "The HC Operating Company FBO P", "trans": "Miscellaneous Credits"}', '{"sign": "1", "ledger": "Manual", "trantype": "Collections"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "MISC CREDIT", "acctn": "The HC Operating Company OPERA", "trans": "Miscellaneous Credits"}', '{"sign": "1", "ledger": "Manual", "reason": "Misc Credit", "trantype": "Disbursement"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "PAYMENT", "acctn": "The HC Operating Company FBO P", "trans": "Miscellaneous Credits"}', '{"sign": "1", "ledger": "Manual", "reason": "Revolver Payment", "trantype": "Revolver Borrow"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "PAYMENT", "acctn": "The HC Operating Company FBO P", "trans": "Miscellaneous Debits"}', '{"sign": "-1", "ledger": "Manual", "reason": "Revolver Payment", "trantype": "Revolver Payment"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "INTTL WIRES IN", "acctn": "The HC Operating Company FBO P", "trans": "Intl Money Transfer Credits"}', '{"sign": "1", "ledger": "AR - Collections", "trantype": "Collections"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "PNC BANK- NJ LOAN PROCEEDS", "acctn": "The HC Operating Company FBO P", "trans": "Money Transfer CR-Other"}', '{"sign": "1", "ledger": "Manual", "reason": "Revolver Advance", "trantype": "Revolver Borrow"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "PNC BANK-PGH LOAN PROCEEDS", "acctn": "The HC Operating Company OPERA", "trans": "Money Transfer CR-Other"}', '{"sign": "1", "ledger": "Manual", "reason": "Revolver Advance", "trantype": "Revolver Borrow"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "FED WIRE IN", "acctn": "The HC Operating Company FBO P", "trans": "Money Transfer CR-Wire"}', '{"sign": "1", "ledger": "AR - Collections", "trantype": "Collections"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "FED WIRE IN", "acctn": "The HC Operating Company OPERA", "trans": "Money Transfer CR-Wire"}', '{"sign": "1", "ledger": "Manual", "reason": "Returned Wires", "trantype": "Disbursement"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "BOOK TRANSFER DEBIT", "acctn": "The HC Operating Company OPERA", "trans": "Money Transfer DB - Other"}', '{"sign": "-1", "ledger": "Manual", "reason": "Returned Item", "trantype": "Disbursement"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "FED WIRE OUT", "acctn": "The HC Operating Company FREIG", "trans": "Money Transfer DB - Wire"}', '{"sign": "-1", "ledger": "Manual", "reason": "Freight Wires", "trantype": "Disbursement"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "FED WIRE OUT", "acctn": "The HC Operating Company OPERA", "trans": "Money Transfer DB - Wire"}', '{"sign": "-1", "ledger": "AP - Wire", "trantype": "Disbursement"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "FED WIRE OUT", "acctn": "The HC Operating Company PAYR", "trans": "Money Transfer DB - Wire"}', '{"sign": "-1", "ledger": "Manual", "trantype": "Disbursement"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "FUNDS TRANSFER FROM ACCT", "acctn": "The HC Operating Company FREIG", "trans": "ZBA Credits"}', '{"sign": "1", "ledger": "Manual", "reason": "ZBA Funding", "trantype": "Funding"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "FUNDS TRANSFER FROM ACCT", "acctn": "The HC Operating Company OPERA", "trans": "ZBA Credits"}', '{"sign": "1", "ledger": "Manual", "reason": "ZBA Funding", "trantype": "Funding"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "FUNDS TRANSFER FROM ACCT", "acctn": "The HC Operating Company PAYR", "trans": "ZBA Credits"}', '{"sign": "1", "ledger": "Manual", "reason": "ZBA Funding", "trantype": "Funding"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "FUNDS TRANSFER TO ACCT", "acctn": "The HC Operating Company OPERA", "trans": "ZBA Debits"}', '{"sign": "-1", "ledger": "Manual", "reason": "ZBA Funding", "trantype": "Funding"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "FUNDS TRANSFER TO ACCT", "acctn": "The HC Operating Company PAYR", "trans": "ZBA Debits"}', '{"sign": "-1", "ledger": "Manual", "reason": "ZBA Funding", "trantype": "Funding"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Currency', '{"ini": "DEPOSIT:", "curr1": ["CREDIT", "USD"], "curr2": ["DEBIT", "CAD"]}', '{"party": "The HC Canada Operating Company, Ltd.", "ledger": "Manual", "reason": "IC - Can to US Settlement", "trantype": "Interco Collection"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "CORPORATE ACCOUNT ANALYSIS CHARGE", "acctn": "The HC Operating Company OPERA", "trans": "Miscellaneous Fees"}', '{"sign": "-1", "party": "PNC", "ledger": "Manual", "reason": "Bank Fees", "trantype": "Fees"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "PNC MERCHANT FINCL ADJ", "acctn": "The HC Operating Company FBO P", "trans": "Miscellaneous Fees"}', '{"sign": "-1", "party": "PNC", "ledger": "Manual", "reason": "Bank Fees", "trantype": "Fees"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "PNC BANK- NJ LOAN PMTS", "acctn": "The HC Operating Company FBO P", "trans": "Miscellaneous Debits"}', '{"sign": "-1", "ledger": "Manual", "reason": "Revolver Payment", "trantype": "Revolver Payment"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "WITHDRAWAL:", "acctn": "The HC Operating Company FBO P", "trans": "Miscellaneous Debits"}', '{"sign": "-1", "ledger": "Manual", "trantype": "Disbursement"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "BOOK TRANSFER CREDIT", "acctn": "The HC Operating Company FBO P", "trans": "Money Transfer CR-Other"}', '{"sign": "1", "ledger": "Manual", "reason": "Returned Item", "trantype": "Collections"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "BOOK TRANSFER CREDIT", "acctn": "The HC Operating Company OPERA", "trans": "Money Transfer CR-Other"}', '{"sign": "1", "ledger": "Manual", "reason": "Returned Item", "trantype": "Collections"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "BOOK TRANSFER CREDIT GHFTDD DDA CREDIT", "acctn": "The HC Operating Company FBO P", "trans": "Money Transfer CR-Other"}', '{"sign": "1", "ledger": "Manual", "reason": "Returned Item", "trantype": "Collections"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "19UDV", "acctn": "The HC Operating Company PAYR", "trans": "ACH Credits"}', '{"sign": "1", "ledger": "Manual", "reason": "Payroll Credits", "trantype": "Disbursement"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "ACH CREDIT RECEIVED", "acctn": "The HC Operating Company FBO P", "trans": "ACH Credits"}', '{"sign": "1", "ledger": "AR - Collections", "trantype": "Collections"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "ACH CREDIT RECEIVED", "acctn": "The HC Operating Company PAYR", "trans": "ACH Credits"}', '{"sign": "1", "ledger": "Manual", "reason": "Payroll Credits", "trantype": "Disbursement"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "ACH CREDIT RETURN", "acctn": "The HC Operating Company OPERA", "trans": "ACH Credits"}', '{"sign": "1", "ledger": "Manual", "reason": "AP ACH Returned", "trantype": "Disbursement"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "ACH DEBIT RECEIVED", "acctn": "The HC Operating Company FBO P", "trans": "ACH Debits"}', '{"sign": "-1", "ledger": "Manual", "reason": "Auto ACH Out", "trantype": "Disbursement"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "ACH DEBIT RECEIVED", "acctn": "The HC Operating Company OPERA", "trans": "ACH Debits"}', '{"sign": "-1", "ledger": "Manual", "reason": "Auto ACH Out", "trantype": "Disbursement"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "ACH DEBIT RECEIVED", "acctn": "The HC Operating Company PAYR", "trans": "ACH Debits"}', '{"sign": "-1", "ledger": "Manual", "reason": "Auto ACH Out", "trantype": "Disbursement"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "CASHED CHECK", "acctn": "The HC Operating Company OPERA", "trans": "Checks Paid"}', '{"sign": "-1", "ledger": "AP - Check Run", "trantype": "Disbursement"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "CASHED CHECK", "acctn": "The HC Operating Company PAYR", "trans": "Checks Paid"}', '{"sign": "-1", "ledger": "Manual", "reason": "Payroll Checks", "trantype": "Disbursement"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "CHECK", "acctn": "The HC Operating Company FREIG", "trans": "Checks Paid"}', '{"sign": "-1", "ledger": "Manual", "reason": "Freight Checks", "trantype": "Disbursement"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "CHECK", "acctn": "The HC Operating Company OPERA", "trans": "Checks Paid"}', '{"sign": "-1", "ledger": "AP - Check Run", "trantype": "Disbursement"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "CHECK", "acctn": "The HC Operating Company PAYR", "trans": "Checks Paid"}', '{"sign": "-1", "ledger": "Manual", "reason": "Payroll Checks", "trantype": "Disbursement"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "SUBSTITUTE CHK", "acctn": "The HC Operating Company FREIG", "trans": "Checks Paid"}', '{"sign": "-1", "ledger": "Manual", "reason": "Freight Checks", "trantype": "Disbursement"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "SUBSTITUTE CHK", "acctn": "The HC Operating Company OPERA", "trans": "Checks Paid"}', '{"sign": "-1", "ledger": "AP - Check Run", "trantype": "Disbursement"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "RET DEP ITEM NSF UN", "acctn": "The HC Operating Company FBO P", "trans": "Deposited Items Returned"}', '{"sign": "-1", "ledger": "Manual", "reason": "Returned Deposit NSF", "trantype": "Collections"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Currency', '{"ini": "WITHDRAWAL:", "curr1": ["DEBIT", "USD"], "curr2": ["CREDIT", "CAD"]}', '{"party": "The HC Canada Operating Company, Ltd.", "ledger": "Manual", "reason": "IC - US to CAN Settlement", "trantype": "Interco Funding"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Currency', '{"ini": "DEPOSIT:", "curr1": ["CREDIT", "USD"], "curr2": ["DEBIT", "USD"]}', '{"party": "The HC Canada Operating Company, Ltd.", "ledger": "Manual", "reason": "IC - round-trip settlement return", "trantype": "Interco Collection"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Currency', '{"ini": "DEPOSIT:", "curr1": ["DEBIT", "USD"], "curr2": ["CREDIT", "CAD"]}', '{"party": "The HC Canada Operating Company, Ltd.", "ledger": "Manual", "reason": "IC - Can to US Settlement", "trantype": "Interco Collection"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "DEPOSIT:", "acctn": "The HC Operating Company OPERA", "trans": "Miscellaneous Credits"}', '{"sign": "1", "ledger": "Manual", "trantype": "Collections"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "SUBSTITUTE CHK", "acctn": "The HC Operating Company PAYR", "trans": "Checks Paid"}', '{"sign": "-1", "ledger": "Manual", "reason": "Payroll Checks", "trantype": "Disbursement"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "ACH DEBIT RETURN", "acctn": "The HC Operating Company OPERA", "trans": "ACH Debits"}', '{"sign": "-1", "ledger": "manual", "trantype": "Disbursement"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "ACH CREDIT SETTLEMENT", "acctn": "The HC Operating Company OPERA", "trans": "ACH Credits"}', '{"sign": "1", "ledger": "manual", "trantype": "Disbursement"}');


--
-- Data for Name: trans_log; Type: TABLE DATA; Schema: tps; Owner: -
--

INSERT INTO trans_log (id, info) VALUES (1, '{"path": "C:\\users\\ptrowbridge\\downloads\\lon_loan_ledgercol.csv", "srce": "PNCL", "inserted": [{"PostDate": "2017-10-17", "Schedule#": "05AR"}, {"PostDate": "2017-10-17", "Schedule#": "MR"}, {"PostDate": "2017-10-20", "Schedule#": "01AR"}, {"PostDate": "2017-10-17", "Schedule#": "03IN Finished Goods"}, {"PostDate": "2017-10-17", "Schedule#": "04AR RS"}, {"PostDate": "2017-10-19", "Schedule#": "01AR"}, {"PostDate": "2017-10-17", "Schedule#": "06AR RS"}, {"PostDate": "2017-10-17", "Schedule#": "02IN Raw Material"}], "time_stamp": "2017-10-25T09:52:10.221392-04:00", "not_inserted": [{"PostDate": "2017-10-18", "Schedule#": "01AR"}, {"PostDate": "2017-10-17", "Schedule#": "01AR"}]}');
INSERT INTO trans_log (id, info) VALUES (2, '{"path": "C:\\users\\ptrowbridge\\downloads\\transsearchcsv(1).csv", "srce": "PNCC", "inserted": [{"AsOfDate": "2017-10-24"}, {"AsOfDate": "2017-10-23"}], "time_stamp": "2017-10-25T10:04:21.618701-04:00", "not_inserted": [{"AsOfDate": "2017-10-19"}, {"AsOfDate": "2017-10-20"}, {"AsOfDate": "2017-10-18"}]}');
INSERT INTO trans_log (id, info) VALUES (3, '{"path": "C:\\users\\ptrowbridge\\downloads\\transsearchcsv(1).csv", "srce": "PNCC", "inserted": null, "time_stamp": "2017-10-25T10:08:11.443367-04:00", "not_inserted": [{"AsOfDate": "2017-10-19"}, {"AsOfDate": "2017-10-24"}, {"AsOfDate": "2017-10-20"}, {"AsOfDate": "2017-10-23"}, {"AsOfDate": "2017-10-18"}]}');
INSERT INTO trans_log (id, info) VALUES (4, '{"path": "C:\\users\\ptrowbridge\\downloads\\llbal.csv", "srce": "PNCO", "inserted": [{"Loan#": "606780191", "Post Date": "2017-10-23", "Effective Date": "2017-10-23"}, {"Loan#": "606780191", "Post Date": "2017-10-24", "Effective Date": "2017-10-24"}], "time_stamp": "2017-10-25T10:13:37.760308-04:00", "not_inserted": [{"Loan#": "606780191", "Post Date": "2017-10-19", "Effective Date": "2017-10-19"}, {"Loan#": "606780191", "Post Date": "2017-10-18", "Effective Date": "2017-10-18"}, {"Loan#": "606780191", "Post Date": "2017-10-20", "Effective Date": "2017-10-20"}]}');
INSERT INTO trans_log (id, info) VALUES (5, '{"path": "C:\\users\\ptrowbridge\\downloads\\llcol.csv", "srce": "PNCL", "inserted": [{"PostDate": "2017-10-24", "Schedule#": "01AR"}, {"PostDate": "2017-10-23", "Schedule#": "01AR"}], "time_stamp": "2017-10-25T10:14:10.004265-04:00", "not_inserted": [{"PostDate": "2017-10-18", "Schedule#": "01AR"}, {"PostDate": "2017-10-17", "Schedule#": "05AR"}, {"PostDate": "2017-10-17", "Schedule#": "MR"}, {"PostDate": "2017-10-20", "Schedule#": "01AR"}, {"PostDate": "2017-10-17", "Schedule#": "03IN Finished Goods"}, {"PostDate": "2017-10-17", "Schedule#": "04AR RS"}, {"PostDate": "2017-10-19", "Schedule#": "01AR"}, {"PostDate": "2017-10-17", "Schedule#": "01AR"}, {"PostDate": "2017-10-17", "Schedule#": "06AR RS"}, {"PostDate": "2017-10-17", "Schedule#": "02IN Raw Material"}]}');


SET search_path = evt, pg_catalog;

--
-- Name: log_id_seq; Type: SEQUENCE SET; Schema: evt; Owner: -
--

SELECT pg_catalog.setval('log_id_seq', 1, false);


SET search_path = tps, pg_catalog;

--
-- Name: trans_id_seq; Type: SEQUENCE SET; Schema: tps; Owner: -
--

SELECT pg_catalog.setval('trans_id_seq', 1544252, true);


--
-- Name: trans_log_id_seq; Type: SEQUENCE SET; Schema: tps; Owner: -
--

SELECT pg_catalog.setval('trans_log_id_seq', 5, true);


--
-- PostgreSQL database dump complete
--

