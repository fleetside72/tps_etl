SELECT
    t.srce
    ,(ae.e::text[])[1] unq_constr
    ,MIN(rec #>> ae.e::text[]) min_text
    ,COUNT(*) cnt
    ,MAX(rec #>> ae.e::text[]) max_text
FROM
    tps.trans t
    INNER JOIN tps.srce s ON
        s.srce = t.srce
    LEFT JOIN LATERAL JSONB_ARRAY_ELEMENTS_TEXT(defn->'unique_constraint'->'fields') WITH ORDINALITY ae(e, rn) ON TRUE
GROUP BY
    t.srce
    ,(ae.e::text[])[1]
ORDER BY
    t.srce
    ,(ae.e::text[])[1]
