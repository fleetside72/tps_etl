INSERT INTO
tps.map_rm
SELECT *
FROM
(VALUES 
    ('PNCC', 'ACH Debits', 
    $j$
    {
        "defn": [
            {
                "key": "{Description}",
                "field": "ini",
                "regex": "([\\w].*?)(?=$| -|\\s[0-9].*?|\\s[\\w/]+?:)"
                ,"retain":"y"
            },
            {
                "key": "{Description}",
                "field": "compn",
                "regex": "Comp Name:(.+?)(?=$| Comp|\\w+?:)"
                ,"retain":"y"
            },
            {
                "key": "{Description}",
                "field": "adp_comp",
                "regex": "Cust ID:.*?(B3X|UDV|U7E|U7C|U7H|U7J).*?(?=$|\\w+?:)"
                ,"retain":"y"
            },
            {
                "key": "{Description}",
                "field": "desc",
                "regex": "Desc:(.+?) Comp"
                ,"retain":"y"
            },
            {
                "key": "{Description}",
                "field": "discr",
                "regex": "Discr:(.+?)(?=$| SEC:|\\w+?:)"
                ,"retain":"y"
            }
        ],
        "where": [
            {
                "Transaction": "ACH Debits"
            }
        ]
    }
    $j$::jsonb
    , 2)
    ,('PNCC', 'Trans Type', 
    $j$
    {
        "defn": [
            {
                "key": "{AccountName}",
                "field": "acctn",
                "regex": "(.*)"
                ,"retain":"n"
            },
            {
                "key": "{Transaction}",
                "field": "trans",
                "regex": "(.*)"
                ,"retain":"n"
            },
            {
                "key": "{Description}",
                "field": "ini",
                "regex": "([\\w].*?)(?=$| -|\\s[0-9].*?|\\s[\\w/]+?:)"
                ,"retain":"y"
            }
        ],
        "where": [
            {
            }
        ]
    }
    $j$::jsonb
    , 1)
    ,('PNCC', 'Wires Out', 
    $j$
    {
        "defn": [
            {
                "key": "{Description}",
                "field": "ini",
                "regex": "([\\w].*?)(?=$| -|\\s[0-9].*?|\\s[\\w/]+?:)"
                ,"retain":"y"
            },
            {
                "key": "{Description}",
                "field": "bene",
                "regex": "BENEFICIARY:(.+?) AC/"
                ,"retain":"y"
            },
            {
                "key": "{Description}",
                "field": "accts",
                "regex": "AC/(\\w*) .*AC/(\\w*) "
                ,"retain":"y"
            }
        ],
        "where": [
            {
                "Transaction": "Intl Money Transfer Debits"
            },
            {
                "Transaction": "Money Transfer DB - Wire"
            }
        ]
    }
    $j$::jsonb
    , 2)
    ,('PNCC', 'Currency', 
    $j$
    {
        "defn": [
            {
                "key": "{Description}",
                "field": "ini",
                "regex": "([\\w].*?)(?=$| -|\\s[0-9].*?|\\s[\\w/]+?:)"
                ,"retain":"y"
            },
            {
                "key": "{Description}",
                "field": "curr1",
                "regex": ".*(DEBIT|CREDIT).*(USD|CAD).*(?=DEBIT|CREDIT).*(?=USD|CAD).*"
                ,"retain":"y"
            },
            {
                "key": "{Description}",
                "field": "curr2",
                "regex": ".*(?=DEBIT|CREDIT).*(?=USD|CAD).*(DEBIT|CREDIT).*(USD|CAD).*"
                ,"retain":"y"
            }
        ],
        "where": [
            {
                "Transaction": "Miscellaneous Credits"
            },
            {
                "Transaction": "Miscellaneous Debits"
            }
        ]
    }
    $j$::jsonb
    , 2)
    ,('PNCC', 'Check Number', 
    $j$
    {
        "defn": [
            {
                "key": "{Description}",
                "field": "checkn",
                "regex": "[^0-9]*([0-9]*)\\s|$"
                ,"retain":"y"
            }
        ],
        "where": [
            {
                "Transaction": "Checks Paid"
            }
        ]
    }
    $j$::jsonb
    , 2)
) x