/*---------------------------------------------------------------------------
turns a single json object into a table suitable for insert to tps.map_rv
this could facilitate a call to a function for inserting many rows from ui
----------------------------------------------------------------------------*/
WITH j AS (
select
$$
[{"source":"DCARD","map":"First 20","ret_val":{"f20": "DISCOUNT DRUG MART 3"},"mapped":{"party":"Discount Drug Mart","reason":"groceries"}},{"source":"DCARD","map":"First 20","ret_val":{"f20": "TARGET STOW OH"},"mapped":{"party":"Target","reason":"groceries"}},{"source":"DCARD","map":"First 20","ret_val":{"f20": "WALMART GROCERY 800-"},"mapped":{"party":"Walmart","reason":"groceries"}},{"source":"DCARD","map":"First 20","ret_val":{"f20": "CIRCLE K 05416 STOW "},"mapped":{"party":"Circle K","reason":"gasoline"}},{"source":"DCARD","map":"First 20","ret_val":{"f20": "TARGET.COM * 800-591"},"mapped":{"party":"Target","reason":"home supplies"}},{"source":"DCARD","map":"First 20","ret_val":{"f20": "ACME NO. 17 STOW OH"},"mapped":{"party":"Acme","reason":"groceries"}},{"source":"DCARD","map":"First 20","ret_val":{"f20": "AT&T *PAYMENT 800-28"},"mapped":{"party":"AT&T","reason":"internet"}},{"source":"DCARD","map":"First 20","ret_val":{"f20": "AUTOZONE #0722 STOW "},"mapped":{"party":"Autozone","reason":"auto maint"}},{"source":"DCARD","map":"First 20","ret_val":{"f20": "BESTBUYCOM8055267948"},"mapped":{"party":"BestBuy","reason":"home supplies"}},{"source":"DCARD","map":"First 20","ret_val":{"f20": "BUFFALO WILD WINGS K"},"mapped":{"party":"Buffalo Wild Wings","reason":"restaurante"}},{"source":"DCARD","map":"First 20","ret_val":{"f20": "CASHBACK BONUS REDEM"},"mapped":{"party":"Discover Card","reason":"financing"}},{"source":"DCARD","map":"First 20","ret_val":{"f20": "CLE CLINIC PT PMTS 2"},"mapped":{"party":"Cleveland Clinic","reason":"medical"}}]
$$::jsonb x
)
SELECT 
	jtr.*
FROM
	j
	LEFT JOIN LATERAL jsonb_array_elements(j.x) ae(v) ON TRUE
	LEFT JOIN LATERAL jsonb_to_record(ae.v) AS jtr(source text, map text, ret_val jsonb, mapped jsonb) ON TRUE