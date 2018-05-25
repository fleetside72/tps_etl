INSERT INTO
    tps.map_rv (srce, target, retval, map, hist)
SELECT 
    r.source
    ,r.map
    ,r.ret_val
    ,r.mapped
    ,jsonb_build_object(
            'hist_defn',mapped
            ,'effective',jsonb_build_array(CURRENT_TIMESTAMP,null::timestamptz)
        ) || '[]'::jsonb
FROM
    JSONB_ARRAY_ELEMENTS(
            $$[{"source":"DCARD","map":"First 20","ret_val":{"f20":"DISCOUNT DRUG MART 3"},"mapped":{"party":"Discount Drug Mart","reason":"groceries"}},{"source":"DCARD","map":"First 20","ret_val":{"f20":"TARGET STOW OH"},"mapped":{"party":"Target","reason":"groceries"}},{"source":"DCARD","map":"First 20","ret_val":{"f20":"WALMART GROCERY 800-"},"mapped":{"party":"Walmart","reason":"groceries"}},{"source":"DCARD","map":"First 20","ret_val":{"f20":"CIRCLE K 05416 STOW "},"mapped":{"party":"Circle K","reason":"gasoline"}},{"source":"DCARD","map":"First 20","ret_val":{"f20":"TARGET.COM * 800-591"},"mapped":{"party":"Target","reason":"home supplies"}},{"source":"DCARD","map":"First 20","ret_val":{"f20":"ACME NO. 17 STOW OH"},"mapped":{"party":"Acme","reason":"groceries"}},{"source":"DCARD","map":"First 20","ret_val":{"f20":"AT&T *PAYMENT 800-28"},"mapped":{"party":"AT&T","reason":"internet"}},{"source":"DCARD","map":"First 20","ret_val":{"f20":"AUTOZONE #0722 STOW "},"mapped":{"party":"Autozone","reason":"auto maint"}},{"source":"DCARD","map":"First 20","ret_val":{"f20":"BESTBUYCOM8055267948"},"mapped":{"party":"BestBuy","reason":"home supplies"}},{"source":"DCARD","map":"First 20","ret_val":{"f20":"BUFFALO WILD WINGS K"},"mapped":{"party":"Buffalo Wild Wings","reason":"restaurante"}},{"source":"DCARD","map":"First 20","ret_val":{"f20":"CASHBACK BONUS REDEM"},"mapped":{"party":"Discover Card","reason":"financing"}},{"source":"DCARD","map":"First 20","ret_val":{"f20":"CLE CLINIC PT PMTS 2"},"mapped":{"party":"Cleveland Clinic","reason":"medical"}}]$$::JSONB
    ) WITH ORDINALITY ae(r,s)
    JOIN LATERAL jsonb_to_record(ae.r) r(source TEXT,map TEXT, ret_val jsonb, mapped jsonb) ON TRUE
ON CONFLICT ON CONSTRAINT map_rv_pk DO UPDATE
    SET
        map = excluded.map
        ,hist = 
            --the new definition going to position -0-
            jsonb_build_object(
                'hist_defn',excluded.map
                ,'effective',jsonb_build_array(CURRENT_TIMESTAMP,null::timestamptz)
            ) 
            --the previous definition, set upper bound of effective range which was previously null
            || jsonb_set(
                map_rv.hist
                ,'{0,effective,1}'::text[]
                ,to_jsonb(CURRENT_TIMESTAMP)
            );
