WITH
x AS (
SELECT
$$
{"vendor":"Drug Mart","date":"2017-08-20","instrument":"Discover Card","item":[{"item":"Green Chili","amount":1.49},{"item":"Black Beans","amount":1.6},{"item":"Distilled Water","amount":7.12},{"item":"Fruit Preservative","amount":3.99},{"item":"Watch Battery","amount":3.79},{"item":"Sales Tax","amount":"0.26"}],"account":[{"account":"food","offset":"dcard","amount":1.49},{"account":"food","offset":"dcard","amount":1.6},{"account":"food","offset":"dcard","amount":7.12},{"account":"food","offset":"dcard","amount":3.99},{"account":"stuff","offset":"dcard","amount":3.79},{"account":"taxes","offset":"dcard","amount":"0.26"}]}
$$::jsonb j
),
acct AS (
SELECT
    rs.*,
    row_number() over() rn
FROM
    x
    JOIN LATERAL jsonb_to_recordset(x.j->'account') rs(account text,"offset" text, amount numeric) ON TRUE
),
item as (
SELECT
    rs.*,
    row_number() over() rn
FROM
    x
    JOIN LATERAL jsonb_to_recordset(x.j->'item') rs(item text, amount numeric) ON TRUE
)
select
	*
from
	item
    INNER JOIN acct ON
    	acct.rn = item.rn