create temp table x	 as (
select
	(rec #>>('{batch}'::text[]))::text as batch
	,(rec #>>('{week}'::text[]))::text as week
	,(rec #>>('{period_end}'::text[]))::text as period_end
    ,(rec #>>('{pay_date}'::text[]))::text as pay_date
    ,(rec #>>('{adp_comp}'::text[]))::text as adp_comp
    ,(rec #>>('{hours_reg}'::text[]))::numeric as hours_reg
    ,(rec #>>('{hours_ot}'::text[]))::numeric as hours_ot
    ,(rec #>>('{adp_dep_home}'::text[]))::text as adp_dep_home
    ,(rec #>>('{adp_dep}'::text[]))::text as adp_dep
    ,(rec #>>('{gl_dep}'::text[]))::text as gl_dep
    ,(rec #>>('{checkn}'::text[]))::text as checkn
    ,(rec #>>('{employee}'::text[]))::text as employee
    ,(rec #>>('{title}'::text[]))::text as title
    ,(rec #>>('{prim_offset}'::text[]))::text as prim_offset
    ,(rec #>>('{cms_tb}'::text[]))::text as cms_tb
    ,(rec #>>('{cms_acct}'::text[]))::text as cms_acct
    ,(rec #>>('{gl_descr}'::text[]))::text as gl_descr
    ,(rec #>>('{amount}'::text[]))::numeric as amount
FROM
	tps.trans
WHERE
	srce = 'ADPRP'
   ) with data

-- SELECT 1603392 Query returned successfully in 13 secs 604 msec.


/*
build to table --> 13 sec
run an aggregate on the table --> 1.5 sec
-versus-
run a basic aggregate on the json data live --> 7 sec
-versus-
run a basic aggregate on the json data with jsonb_popualte_record --> 8 sec
*/