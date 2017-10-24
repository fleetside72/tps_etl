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

INSERT INTO map_rm (srce, target, regex, seq) VALUES ('PNCC', 'ACH Debits', '{"defn": [{"key": "{Description}", "field": "ini", "regex": "([\\w].*?)(?=$| -|\\s[0-9].*?|\\s[\\w/]+?:)", "retain": "y"}, {"key": "{Description}", "field": "compn", "regex": "Comp Name:(.+?)(?=$| Comp|\\w+?:)", "retain": "y"}, {"key": "{Description}", "field": "adp_comp", "regex": "Cust ID:.*?(B3X|UDV|U7E|U7C|U7H|U7J).*?(?=$|\\w+?:)", "retain": "y"}, {"key": "{Description}", "field": "desc", "regex": "Desc:(.+?) Comp", "retain": "y"}, {"key": "{Description}", "field": "discr", "regex": "Discr:(.+?)(?=$| SEC:|\\w+?:)", "retain": "y"}], "where": [{"Transaction": "ACH Debits"}]}', 2);
INSERT INTO map_rm (srce, target, regex, seq) VALUES ('PNCC', 'Trans Type', '{"defn": [{"key": "{AccountName}", "field": "acctn", "regex": "(.*)", "retain": "n"}, {"key": "{Transaction}", "field": "trans", "regex": "(.*)", "retain": "n"}, {"key": "{Description}", "field": "ini", "regex": "([\\w].*?)(?=$| -|\\s[0-9].*?|\\s[\\w/]+?:)", "retain": "y"}], "where": [{}]}', 1);
INSERT INTO map_rm (srce, target, regex, seq) VALUES ('PNCC', 'Wires Out', '{"defn": [{"key": "{Description}", "field": "ini", "regex": "([\\w].*?)(?=$| -|\\s[0-9].*?|\\s[\\w/]+?:)", "retain": "y"}, {"key": "{Description}", "field": "bene", "regex": "BENEFICIARY:(.+?) AC/", "retain": "y"}, {"key": "{Description}", "field": "accts", "regex": "AC/(\\w*) .*AC/(\\w*) ", "retain": "y"}], "where": [{"Transaction": "Intl Money Transfer Debits"}, {"Transaction": "Money Transfer DB - Wire"}]}', 2);
INSERT INTO map_rm (srce, target, regex, seq) VALUES ('PNCC', 'Currency', '{"defn": [{"key": "{Description}", "field": "ini", "regex": "([\\w].*?)(?=$| -|\\s[0-9].*?|\\s[\\w/]+?:)", "retain": "y"}, {"key": "{Description}", "field": "curr1", "regex": ".*(DEBIT|CREDIT).*(USD|CAD).*(?=DEBIT|CREDIT).*(?=USD|CAD).*", "retain": "y"}, {"key": "{Description}", "field": "curr2", "regex": ".*(?=DEBIT|CREDIT).*(?=USD|CAD).*(DEBIT|CREDIT).*(USD|CAD).*", "retain": "y"}], "where": [{"Transaction": "Miscellaneous Credits"}, {"Transaction": "Miscellaneous Debits"}]}', 2);
INSERT INTO map_rm (srce, target, regex, seq) VALUES ('PNCC', 'Check Number', '{"defn": [{"key": "{Description}", "field": "checkn", "regex": "[^0-9]*([0-9]*)\\s|$", "retain": "y"}], "where": [{"Transaction": "Checks Paid"}]}', 2);


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
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Wires Out', '{"ini": "INTL WIRES OUT", "accts": ["8026322346", "010241000355"]}', '{"party": "The HC Canada Operating Company, Ltd.", "ledger": "Manual", "reason": "IC - permanent AP funding"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Wires Out', '{"ini": "INTL WIRES OUT", "accts": ["8026322346", "010244001145"]}', '{"party": "The HC Canada Operating Company, Ltd.", "ledger": "Manual", "reason": "IC - round-trip settlement outbound"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Wires Out', '{"ini": "INTL WIRES OUT", "accts": ["8026322346", "010244001152"]}', '{"party": "The HC Canada Operating Company, Ltd.", "ledger": "Manual", "reason": "IC - permanent AP funding"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Wires Out', '{"ini": "FED WIRE OUT", "bene": "ADP LLC", "accts": ["8026322346", "00153170"]}', '{"party": "ADP", "ledger": "Manual", "reason": "Payroll"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Wires Out', '{"ini": "FED WIRE OUT", "bene": "ADP LLC", "accts": ["8026322346", "00412283"]}', '{"party": "ADP", "ledger": "Manual", "reason": "Payroll"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Wires Out', '{"ini": "FED WIRE OUT", "bene": "ADP PAYROLL TAX DEPOSIT CUSTODIAN", "accts": ["8026322338", "00153170"]}', '{"party": "ADP", "ledger": "Manual", "reason": "Payroll"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Wires Out', '{"ini": "FED WIRE OUT", "bene": "ADP TAX SVCS INC. REV. WIRE IMPOUND", "accts": ["8026322338", "00416217"]}', '{"party": "ADP", "ledger": "Manual", "reason": "Payroll Direct Deposit"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'ACH Debits', '{"ini": "ACH DEBIT RECEIVED", "compn": " NEVADA TAX"}', '{"party": "State of Nevada", "reason": "Sales & Use Tax"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'ACH Debits', '{"ini": "ACH DEBIT RECEIVED", "desc": " ADP - TAX", "compn": " ADP TX/FINCL SVC"}', '{"party": "ADP", "reason": "Payroll"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'ACH Debits', '{"ini": "ACH DEBIT RECEIVED", "desc": " ANTHEM", "compn": " ANTHEM"}', '{"party": "Anthem", "reason": "Healthcare Costs"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'ACH Debits', '{"ini": "ACH DEBIT RECEIVED", "desc": " TAX/401K", "compn": " ADP TAX/401K"}', '{"party": "ADP", "reason": "Payroll Taxes"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "CORPORATE ACCOUNT ANALYSIS CHARGE", "acctn": "The HC Operating Company OPERA", "trans": "Miscellaneous Fees"}', '{"sign": "-1", "party": "PNC", "ledger": "Manual", "reason": "Bank Fees", "trantype": "Fees"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "PNC MERCHANT FINCL ADJ", "acctn": "The HC Operating Company FBO P", "trans": "Miscellaneous Fees"}', '{"sign": "-1", "party": "PNC", "ledger": "Manual", "reason": "Bank Fees", "trantype": "Fees"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'ACH Debits', '{"ini": "ACH DEBIT RECEIVED", "desc": " ASO CLAIMS", "compn": " UNUM STD"}', '{"party": "Unum", "reason": "Short Term Disability"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "PNC BANK- NJ LOAN PMTS", "acctn": "The HC Operating Company FBO P", "trans": "Miscellaneous Debits"}', '{"sign": "-1", "ledger": "Manual", "reason": "Revolver Payment", "trantype": "Revolver Payment"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "WITHDRAWAL:", "acctn": "The HC Operating Company FBO P", "trans": "Miscellaneous Debits"}', '{"sign": "-1", "ledger": "Manual", "trantype": "Disbursement"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "BOOK TRANSFER CREDIT", "acctn": "The HC Operating Company FBO P", "trans": "Money Transfer CR-Other"}', '{"sign": "1", "ledger": "Manual", "reason": "Returned Item", "trantype": "Collections"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "BOOK TRANSFER CREDIT", "acctn": "The HC Operating Company OPERA", "trans": "Money Transfer CR-Other"}', '{"sign": "1", "ledger": "Manual", "reason": "Returned Item", "trantype": "Collections"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "BOOK TRANSFER CREDIT GHFTDD DDA CREDIT", "acctn": "The HC Operating Company FBO P", "trans": "Money Transfer CR-Other"}', '{"sign": "1", "ledger": "Manual", "reason": "Returned Item", "trantype": "Collections"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'ACH Debits', '{"ini": "ACH DEBIT RECEIVED", "desc": " AXP DISCNT", "compn": " AMERICAN EXPRESS"}', '{"party": "American Express", "reason": "Credit Card Fees"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'ACH Debits', '{"ini": "ACH DEBIT RECEIVED", "desc": " BNKCRD DEP", "compn": " WORLDPAY"}', '{"party": "Worldpay", "reason": "Credit Card Fees"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'ACH Debits', '{"ini": "ACH DEBIT RECEIVED", "desc": " C01", "compn": " FLA DEPT REVENUE"}', '{"party": "Florida", "reason": "Sales & Tax"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'ACH Debits', '{"ini": "ACH DEBIT RECEIVED", "desc": " DBI ADMIN", "compn": " DISCOVERY BENEFI"}', '{"party": "Discovery Benefits", "reason": "Benefits Administration"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'ACH Debits', '{"ini": "ACH DEBIT RECEIVED", "desc": " DEBITS", "compn": " OHIO BWC", "discr": " OHIO BWC PREMIUM"}', '{"party": "Ohio BWC", "reason": "Workers Comp Premium"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'ACH Debits', '{"ini": "ACH DEBIT RECEIVED", "desc": " INSURANCE", "compn": " UNUMGROUP955"}', '{"party": "Unum", "reason": "Insurance"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'ACH Debits', '{"ini": "ACH DEBIT RECEIVED", "desc": " INTEREST", "compn": " DERIVATIVES"}', '{"party": "PNC", "reason": "Derivatives Interest"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'ACH Debits', '{"ini": "ACH DEBIT RECEIVED", "desc": " LEASE RENT", "compn": " RAYMOND LEASING"}', '{"party": "Raymond Leasing", "reason": "Lease Expense"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'ACH Debits', '{"ini": "ACH DEBIT RECEIVED", "desc": " MTHLY CHGS", "compn": " WORLDPAY"}', '{"party": "Worlpay", "reason": "Credit Card Fees"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'ACH Debits', '{"ini": "ACH DEBIT RECEIVED", "desc": " OH CAT RTN", "compn": " 8012OHIO-TAXOCAT"}', '{"party": "State of Ohio", "reason": "CAT"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'ACH Debits', '{"ini": "ACH DEBIT RECEIVED", "desc": " OH REG VL", "compn": " 8008OHIO-TAXORVL"}', '{"party": "State of Ohio", "reason": "Vendor License"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'ACH Debits', '{"ini": "ACH DEBIT RECEIVED", "desc": " OH SALESTX", "compn": " 8013OHIO-TAXOSUT"}', '{"party": "State of Ohio", "reason": "Sales & Use Tax"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'ACH Debits', '{"ini": "ACH DEBIT RECEIVED", "desc": " OH TAXASMT", "compn": " 8001OHIO-TAXSUAP"}', '{"party": "State of Ohio", "reason": "Sales & Use Tax"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'ACH Debits', '{"ini": "ACH DEBIT RECEIVED", "desc": " OHATTYGN", "compn": " OH ATTORNYGENRAL"}', '{"party": "Ohio Attorney General", "reason": "Sales & Use Tax"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'ACH Debits', '{"ini": "ACH DEBIT RECEIVED", "desc": " PLIC-PERIS", "compn": " PRINCIPAL LIFE P"}', '{"party": "Principal", "reason": "401k"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'ACH Debits', '{"ini": "ACH DEBIT RECEIVED", "desc": " PROGRAM", "compn": " USDEPTHHSCMS"}', '{"party": "US Dept of HHS", "reason": "Health tax"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'ACH Debits', '{"ini": "ACH DEBIT RECEIVED", "desc": " RIPAYMENT", "compn": " USDEPTHHSCMS"}', '{"party": "US Dept of HHS", "reason": "Health tax"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'ACH Debits', '{"ini": "ACH DEBIT RECEIVED", "desc": " TAX PMT", "compn": " WA ST DEPT REV"}', '{"party": "Washington State", "reason": "Sales & Use Tax"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'ACH Debits', '{"ini": "ACH DEBIT RECEIVED", "desc": " UCC FILING", "compn": " RAYMOND LEASING"}', '{"party": "Raymond Leasing", "reason": "Lease Expense"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'ACH Debits', '{"ini": "ACH DEBIT RECEIVED", "desc": " USATAXPYMT", "compn": " IRS"}', '{"party": "IRS", "reason": "Federal Tax"}');
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
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'ACH Debits', '{"ini": "ACH DEBIT RECEIVED", "desc": " EEPAY/GARN", "compn": " ADP EEPAY/GARNWC"}', '{"party": "ADP", "reason": "Payroll Direct Deposit & Garnishments"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Currency', '{"ini": "DEPOSIT:", "curr1": ["CREDIT", "USD"], "curr2": ["DEBIT", "USD"]}', '{"party": "The HC Canada Operating Company, Ltd.", "ledger": "Manual", "reason": "IC - round-trip settlement return", "trantype": "Interco Collection"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Currency', '{"ini": "DEPOSIT:", "curr1": ["DEBIT", "USD"], "curr2": ["CREDIT", "CAD"]}', '{"party": "The HC Canada Operating Company, Ltd.", "ledger": "Manual", "reason": "IC - Can to US Settlement", "trantype": "Interco Collection"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'ACH Debits', '{"ini": "ACH DEBIT RECEIVED", "desc": " ADP TAX", "compn": " ADP TAX"}', '{"party": "ADP", "reason": "Payroll Taxes"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "DEPOSIT:", "acctn": "The HC Operating Company OPERA", "trans": "Miscellaneous Credits"}', '{"sign": "1", "ledger": "Manual", "trantype": "Collections"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'Trans Type', '{"ini": "SUBSTITUTE CHK", "acctn": "The HC Operating Company PAYR", "trans": "Checks Paid"}', '{"sign": "-1", "ledger": "Manual", "reason": "Payroll Checks", "trantype": "Disbursement"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'ACH Debits', '{"ini": "ACH DEBIT RECEIVED", "desc": " WAGE GARN", "compn": " ADP WAGE GARN"}', '{"party": "ADP", "reason": "Payroll Garnishments"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'ACH Debits', '{"ini": "ACH DEBIT RECEIVED", "desc": " WAGE PAY", "compn": " ADP WAGE PAY"}', '{"party": "ADP", "reason": "Payroll Direct Deposit"}');
INSERT INTO map_rv (srce, target, retval, map) VALUES ('PNCC', 'ACH Debits', '{"ini": "ACH DEBIT RECEIVED", "desc": " DBI COBRA", "compn": " DBI COBRA"}', '{"party": "ADP", "reason": "Payroll Direct Deposit"}');


--
-- Data for Name: trans_log; Type: TABLE DATA; Schema: tps; Owner: -
--



SET search_path = evt, pg_catalog;

--
-- Name: log_id_seq; Type: SEQUENCE SET; Schema: evt; Owner: -
--

SELECT pg_catalog.setval('log_id_seq', 1, false);


SET search_path = tps, pg_catalog;

--
-- Name: trans_id_seq; Type: SEQUENCE SET; Schema: tps; Owner: -
--

SELECT pg_catalog.setval('trans_id_seq', 1544080, true);


--
-- Name: trans_log_id_seq; Type: SEQUENCE SET; Schema: tps; Owner: -
--

SELECT pg_catalog.setval('trans_log_id_seq', 1, false);


--
-- PostgreSQL database dump complete
--

