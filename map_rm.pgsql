SELECT
jsonb_pretty(
$$
{
    "defn": [
        {
            "key": "{Description}",
            "field": "ini",
            "regex": "([\\w].*?)(?=$| -|\\s[0-9].*?|\\s[\\w/]+?:)"
        },
        {
            "key": "{Description}",
            "field": "compn",
            "regex": "Comp Name:(.+?)(?=$| Comp|\\w+?:)"
        },
        {
            "key": "{Description}",
            "field": "adp_comp",
            "regex": "Cust ID:.*?(B3X|UDV|U7E|U7C|U7H|U7J).*?(?=$|\\w+?:)"
        },
        {
            "key": "{Description}",
            "field": "desc",
            "regex": "Desc:(.+?) Comp"
        },
        {
            "key": "{Description}",
            "field": "discr",
            "regex": "Discr:(.+?)(?=$| SEC:|\\w+?:)"
        }
    ],
    "type": "extract",
    "where": [
        {
            "Transaction": "ACH Debits"
        }
    ]
}
$$::jsonb
)