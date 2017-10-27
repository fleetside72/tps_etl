
UPDATE tps.map_rm  
SET regex = 
    $j$
    {
        "name":"Strip Amount Commas",
        "description":"the Amount field come from PNC with commas embeded so it cannot be cast to numeric",
        "defn": [
            {
                "key": "{Amount}",
                "field": "amount",
                "regex": ",",
                "replace":"",
                "flag":"g",
                "retain":"y"
            }
        ],
        "function":"replace",
        "map":"no",
        "where": [
            {
            }
        ]
    }
    $j$::jsonb
WHERE 
    target = 'Strip Amount Commas';

UPDATE tps.map_rm  
SET regex =  
    $j$
    {
        "name":"Parse ACH",
        "description":"parse select components of the description for ACH Credits Receieved",
        "defn": [
            {
                "key": "{Description}",
                "field":"Comp Name",
                "regex": "Comp Name:(.+?)(?=SEC:|Cust ID:|Desc:|Comp Name:|Comp ID:|Batch Discr:|Cust Name:|Addenda:|SETT:|Date:|Time:|$)",
                "flag":"",
                "retain":"y"
            },
            {
                "key": "{Description}",
                "field":"Cust ID",
                "regex": "Cust ID:(.+?)(?=SEC:|Cust ID:|Desc:|Comp Name:|Comp ID:|Batch Discr:|Cust Name:|Addenda:|SETT:|Date:|Time:|$)",
                "flag":"",
                "retain":"y"
            },
            {
                "key": "{Description}",
                "field":"Desc",
                "regex": "Desc:(.+?)(?=SEC:|Cust ID:|Desc:|Comp Name:|Comp ID:|Batch Discr:|Cust Name:|Addenda:|SETT:|Date:|Time:|$)",
                "flag":"",
                "retain":"y"
            },
            {
                "key": "{Description}",
                "field":"Cust Name",
                "regex": "Cust Name:(.+?)(?=SEC:|Cust ID:|Desc:|Comp Name:|Comp ID:|Batch Discr:|Cust Name:|Addenda:|SETT:|Date:|Time:|$)",
                "flag":"",
                "retain":"y"
            },
            {
                "key": "{Description}",
                "field":"Batch Discr",
                "regex": "Batch Discr:(.+?)(?=SEC:|Cust ID:|Desc:|Comp Name:|Comp ID:|Batch Discr:|Cust Name:|Addenda:|SETT:|Date:|Time:|$)",
                "flag":"",
                "retain":"y"
            },
            {
                "key": "{Description}",
                "field":"Comp ID",
                "regex": "Comp ID:(.+?)(?=SEC:|Cust ID:|Desc:|Comp Name:|Comp ID:|Batch Discr:|Cust Name:|Addenda:|SETT:|Date:|Time:|$)",
                "flag":"",
                "retain":"y"
            },
            {
                "key": "{Description}",
                "field":"Addenda",
                "regex": "Addenda:(.+?)(?=SEC:|Cust ID:|Desc:|Comp Name:|Comp ID:|Batch Discr:|Cust Name:|Addenda:|SETT:|Date:|Time:|$)",
                "flag":"",
                "retain":"y"
            },
            {
                "key": "{Description}",
                "field":"SETT",
                "regex": "SETT:(.+?)(?=SEC:|Cust ID:|Desc:|Comp Name:|Comp ID:|Batch Discr:|Cust Name:|Addenda:|SETT:|Date:|Time:|$)",
                "flag":"",
                "retain":"y"
            },
            {
                "key": "{Description}",
                "field":"Date",
                "regex": "Date:(.+?)(?=SEC:|Cust ID:|Desc:|Comp Name:|Comp ID:|Batch Discr:|Cust Name:|Addenda:|SETT:|Date:|Time:|$)",
                "flag":"",
                "retain":"y"
            },
            {
                "key": "{Description}",
                "field":"Time",
                "regex": "Time:(.+?)(?=SEC:|Cust ID:|Desc:|Comp Name:|Comp ID:|Batch Discr:|Cust Name:|Addenda:|SETT:|Date:|Time:|$)",
                "flag":"",
                "retain":"y"
            }
        ],
        "function":"extract",
        "map":"no",
        "where": [
            {
                "Transaction":"ACH Credits"
            },
            {
                "Transaction":"ACH Debits"
            }
        ]
    }
    $j$::jsonb
WHERE target = 'Parse ACH';

UPDATE tps.map_rm  
SET regex = 
    $j$
    {
        "name":"Parse Wires",
        "description":"pull out whatever follows OBI in the description until atleast 3 capital letters followed by a colon are encountered",
        "defn": [
            {
                "key": "{Description}",
                "field": "dparse",
                "regex": "([A-Z]{3,}?:)(.*)(?=[A-Z]{3,}?:|$)",
                "flag":"g",
                "retain":"y"
            },
            {
                "key": "{Description}",
                "field": "beneficiary_components",
                "regex": "BENEFICIARY:(.*?)AC/(\\d*) (.*)(?=[A-Z]{3,}?:|$)",
                "flag":"",
                "retain":"y"
            },
            {
                "key": "{Description}",
                "field": "originator_components",
                "regex": "ORIGINATOR:(.*?)AC/(\\d*) (.*)(?=[A-Z]{3,}?:|$)",
                "flag":"",
                "retain":"y"
            },
            {
                "key": "{Description}",
                "field": "OBI",
                "regex": "OBI:(.*?)(?=[A-Z]{3,}?:|$)",
                "flag":"",
                "retain":"y"
            },
            {
                "key": "{Description}",
                "field": "RFB",
                "regex": "RFB:(.*?)(?=[A-Z]{3,}?:|$)",
                "flag":"",
                "retain":"y"
            },
            {
                "key": "{Description}",
                "field": "ABA",
                "regex": "ABA:(.*?)(?=[A-Z]{3,}?:|$)",
                "flag":"",
                "retain":"y"
            },
            {
                "key": "{Description}",
                "field": "BBI",
                "regex": "BBI:(.*?)(?=[A-Z]{3,}?:|$)",
                "flag":"",
                "retain":"y"
            },
            {
                "key": "{Description}",
                "field": "BENEBNK",
                "regex": "BENEBNK:(.*?)(?=[A-Z]{3,}?:|$)",
                "flag":"",
                "retain":"y"
            },
            {
                "key": "{Description}",
                "field": "IBK",
                "regex": "IBK:(.*?)(?=[A-Z]{3,}?:|$)",
                "flag":"",
                "retain":"y"
            },
            {
                "key": "{Description}",
                "field": "RATE",
                "regex": "RATE:(.*?)(?=[A-Z]{3,}?:|$)",
                "flag":"",
                "retain":"y"
            },
            {
                "key": "{Description}",
                "field": "RECVBNK",
                "regex": "RECVBNK:(.*?)(?=[A-Z]{3,}?:|$)",
                "flag":"",
                "retain":"y"
            }
        ],
        "function":"extract",
        "map":"no",
        "where": [
            {
                "Transaction":"Money Transfer DB - Wire"
            },
            {
                "Transaction":"Money Transfer DB - Other"
            },
            {
                "Transaction":"Money Transfer CR-Wire"
            },
            {
                "Transaction":"Money Transfer CR-Other"
            },
            {
                "Transaction":"Intl Money Transfer Debits"
            },
            {
                "Transaction":"Intl Money Transfer Credits"
            }
        ]
    }
    $j$::jsonb
  WHERE target = 'Parse Wires';


UPDATE tps.map_rm  
SET regex = 
    $j$
        {
            "name":"Trans Type",
            "description":"extract intial description in conjunction with account name and transaction type for mapping",
            "map": "yes",
            "defn": [
                {
                    "key": "{AccountName}",
                    "field": "acctn",
                    "regex": "(.*)",
                    "retain": "n"
                },
                {
                    "key": "{Transaction}",
                    "field": "trans",
                    "regex": "(.*)",
                    "retain": "n"
                },
                {
                    "key": "{Description}",
                    "field": "ini",
                    "regex": "([\\w].*?)(?=$| -|\\s[0-9].*?|\\s[\\w/]+?:)",
                    "retain": "y"
                }
            ],
            "where": [
                {
                }
            ],
            "function": "extract"
        }
    $j$::jsonb
  WHERE target = 'Trans Type';


UPDATE tps.map_rm  
SET regex = 
    $j$
        {
            "name":"Currency",
            "description":"pull out currency indicators from description of misc items and map",
            "map": "yes",
            "defn": [
                {
                    "key": "{Description}",
                    "field": "ini",
                    "regex": "([\\w].*?)(?=$| -|\\s[0-9].*?|\\s[\\w/]+?:)",
                    "retain": "y"
                },
                {
                    "key": "{Description}",
                    "field": "curr1",
                    "regex": ".*(DEBIT|CREDIT).*(USD|CAD).*(?=DEBIT|CREDIT).*(?=USD|CAD).*",
                    "retain": "y"
                },
                {
                    "key": "{Description}",
                    "field": "curr2",
                    "regex": ".*(?=DEBIT|CREDIT).*(?=USD|CAD).*(DEBIT|CREDIT).*(USD|CAD).*",
                    "retain": "y"
                }
            ],
            "where": [
                {
                    "Transaction": "Miscellaneous Credits"
                },
                {
                    "Transaction": "Miscellaneous Debits"
                }
            ],
            "function": "extract"
        }
    $j$::jsonb
  WHERE target = 'Currency';

UPDATE tps.map_rm  
SET regex = 
    $j$
        {
            "map": "yes",
            "defn": [
                {
                    "key": "{Description}",
                    "field": "checkn",
                    "regex": "[^0-9]*([0-9]*)\\s|$",
                    "retain": "y"
                }
            ],
            "where": [
                {
                    "Transaction": "Checks Paid"
                }
            ],
            "function": "extract"
        }
    $j$::jsonb
  WHERE target = 'Check Number';