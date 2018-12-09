
select jsonb_pretty(x.r) from tps.test_regex_recs(
$$
{
    "name": "Trans Type",
    "srce": "PNCC",
    "regex": {
        "function": "extract",
        "defn": [
            {
                "key": "{AccountName}",
                "map": "y",
                "field": "acctn",
                "regex": "(.*)",
                "retain": "n"
            },
            {
                "key": "{Transaction}",
                "map": "y",
                "field": "trans",
                "regex": "(.*)",
                "retain": "n"
            },
            {
                "key": "{Description}",
                "map": "y",
                "field": "ini",
                "regex": "([\\w].*?)(?=$| -|\\s[0-9].*?|\\s[\\w/]+?:)",
                "retain": "y"
            }
        ],
        "where": [
            {}
        ]
    },
    "sequence": 1
}
$$::jsonb
) x(r)
limit 1