
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
                "retain":"y",
                "map":"n"
            }
        ],
        "function":"replace",
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
        "name":"Parse ACH Credits",
        "description":"parse select components of the description for ACH Credits Receieved",
        "defn": [
            {
                "key": "{Description}",
                "field":"beneficiary",
                "regex": "Comp Name:(.+?)(?=\\d{6} Com|SEC:|Cust ID:|Desc:|Comp Name:|Comp ID:|Batch Discr:|Cust Name:|Addenda:|SETT:|Date:|Time:|$)",
                "flag":"",
                "retain":"y",
                "map":"n"
            },
            {
                "key": "{Description}",
                "field":"Cust ID",
                "regex": "Cust ID:(.+?)(?=SEC:|Cust ID:|Desc:|Comp Name:|Comp ID:|Batch Discr:|Cust Name:|Addenda:|SETT:|Date:|Time:|$)",
                "flag":"",
                "retain":"y",
                "map":"n"
            },
            {
                "key": "{Description}",
                "field":"Desc",
                "regex": "Desc:(.+?)(?=SEC:|Cust ID:|Desc:|Comp Name:|Comp ID:|Batch Discr:|Cust Name:|Addenda:|SETT:|Date:|Time:|$)",
                "flag":"",
                "retain":"y",
                "map":"n"
            },
            {
                "key": "{Description}",
                "field":"originator",
                "regex": "Cust Name:(.+?)(?=SEC:|Cust ID:|Desc:|Comp Name:|Comp ID:|Batch Discr:|Cust Name:|Addenda:|SETT:|Date:|Time:|$)",
                "flag":"",
                "retain":"y",
                "map":"n"
            },
            {
                "key": "{Description}",
                "field":"Batch Discr",
                "regex": "Batch Discr:(.+?)(?=SEC:|Cust ID:|Desc:|Comp Name:|Comp ID:|Batch Discr:|Cust Name:|Addenda:|SETT:|Date:|Time:|$)",
                "flag":"",
                "retain":"y",
                "map":"n"
            },
            {
                "key": "{Description}",
                "field":"Comp ID",
                "regex": "Comp ID:(.+?)(?=SEC:|Cust ID:|Desc:|Comp Name:|Comp ID:|Batch Discr:|Cust Name:|Addenda:|SETT:|Date:|Time:|$)",
                "flag":"",
                "retain":"y",
                "map":"n"
            },
            {
                "key": "{Description}",
                "field":"Addenda",
                "regex": "Addenda:(.+?)(?=SEC:|Cust ID:|Desc:|Comp Name:|Comp ID:|Batch Discr:|Cust Name:|Addenda:|SETT:|Date:|Time:|$)",
                "flag":"",
                "retain":"y",
                "map":"n"
            },
            {
                "key": "{Description}",
                "field":"SETT",
                "regex": "SETT:(.+?)(?=SEC:|Cust ID:|Desc:|Comp Name:|Comp ID:|Batch Discr:|Cust Name:|Addenda:|SETT:|Date:|Time:|$)",
                "flag":"",
                "retain":"y",
                "map":"n"
            },
            {
                "key": "{Description}",
                "field":"Date",
                "regex": "Date:(.+?)(?=SEC:|Cust ID:|Desc:|Comp Name:|Comp ID:|Batch Discr:|Cust Name:|Addenda:|SETT:|Date:|Time:|$)",
                "flag":"",
                "retain":"y",
                "map":"n"
            },
            {
                "key": "{Description}",
                "field":"Time",
                "regex": "Time:(.+?)(?=SEC:|Cust ID:|Desc:|Comp Name:|Comp ID:|Batch Discr:|Cust Name:|Addenda:|SETT:|Date:|Time:|$)",
                "flag":"",
                "retain":"y",
                "map":"n"
            }
        ],
        "function":"extract",
        "where": [
            {
                "Transaction":"ACH Credits"
            }
        ]
    }
    $j$::jsonb
WHERE target = 'Parse ACH Credits';


UPDATE tps.map_rm  
SET regex =  
    $j$
    {
        "name":"Parse ACH Debits",
        "description":"parse select components of the description for ACH Credits Receieved",
        "defn": [
            {
                "key": "{Description}",
                "field":"originator",
                "regex": "Comp Name:(.+?)(?=\\d{6} Com|SEC:|Cust ID:|Desc:|Comp Name:|Comp ID:|Batch Discr:|Cust Name:|Addenda:|SETT:|Date:|Time:|$)",
                "flag":"",
                "retain":"y",
                "map":"n"
            },
            {
                "key": "{Description}",
                "field":"Cust ID",
                "regex": "Cust ID:(.+?)(?=SEC:|Cust ID:|Desc:|Comp Name:|Comp ID:|Batch Discr:|Cust Name:|Addenda:|SETT:|Date:|Time:|$)",
                "flag":"",
                "retain":"y",
                "map":"n"
            },
            {
                "key": "{Description}",
                "field":"Desc",
                "regex": "Desc:(.+?)(?=SEC:|Cust ID:|Desc:|Comp Name:|Comp ID:|Batch Discr:|Cust Name:|Addenda:|SETT:|Date:|Time:|$)",
                "flag":"",
                "retain":"y",
                "map":"n"
            },
            {
                "key": "{Description}",
                "field":"beneficiary",
                "regex": "Cust Name:(.+?)(?=SEC:|Cust ID:|Desc:|Comp Name:|Comp ID:|Batch Discr:|Cust Name:|Addenda:|SETT:|Date:|Time:|$)",
                "flag":"",
                "retain":"y",
                "map":"n"
            },
            {
                "key": "{Description}",
                "field":"Batch Discr",
                "regex": "Batch Discr:(.+?)(?=SEC:|Cust ID:|Desc:|Comp Name:|Comp ID:|Batch Discr:|Cust Name:|Addenda:|SETT:|Date:|Time:|$)",
                "flag":"",
                "retain":"y",
                "map":"n"
            },
            {
                "key": "{Description}",
                "field":"Comp ID",
                "regex": "Comp ID:(.+?)(?=SEC:|Cust ID:|Desc:|Comp Name:|Comp ID:|Batch Discr:|Cust Name:|Addenda:|SETT:|Date:|Time:|$)",
                "flag":"",
                "retain":"y",
                "map":"n"
            },
            {
                "key": "{Description}",
                "field":"Addenda",
                "regex": "Addenda:(.+?)(?=SEC:|Cust ID:|Desc:|Comp Name:|Comp ID:|Batch Discr:|Cust Name:|Addenda:|SETT:|Date:|Time:|$)",
                "flag":"",
                "retain":"y",
                "map":"n"
            },
            {
                "key": "{Description}",
                "field":"SETT",
                "regex": "SETT:(.+?)(?=SEC:|Cust ID:|Desc:|Comp Name:|Comp ID:|Batch Discr:|Cust Name:|Addenda:|SETT:|Date:|Time:|$)",
                "flag":"",
                "retain":"y",
                "map":"n"
            },
            {
                "key": "{Description}",
                "field":"Date",
                "regex": "Date:(.+?)(?=SEC:|Cust ID:|Desc:|Comp Name:|Comp ID:|Batch Discr:|Cust Name:|Addenda:|SETT:|Date:|Time:|$)",
                "flag":"",
                "retain":"y",
                "map":"n"
            },
            {
                "key": "{Description}",
                "field":"Time",
                "regex": "Time:(.+?)(?=SEC:|Cust ID:|Desc:|Comp Name:|Comp ID:|Batch Discr:|Cust Name:|Addenda:|SETT:|Date:|Time:|$)",
                "flag":"",
                "retain":"y",
                "map":"n"
            }
        ],
        "function":"extract",
        "where": [
            {
                "Transaction":"ACH Debits"
            }
        ]
    }
    $j$::jsonb
WHERE target = 'Parse ACH Debits';

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
                "retain":"y",
                "map":"n"
            },
            {
                "key": "{Description}",
                "field": "beneficiary_components",
                "regex": "BENEFICIARY:(.*?)AC/(\\d*) (.*)(?=[A-Z]{3,}?:|$)",
                "flag":"",
                "retain":"y",
                "map":"n"
            },
            {
                "key": "{Description}",
                "field": "originator_components",
                "regex": "ORIGINATOR:(.*?)AC/(\\d*) (.*)(?=[A-Z]{3,}?:|$)",
                "flag":"",
                "retain":"y",
                "map":"n"
            },
            {
                "key": "{Description}",
                "field": "beneficiary",
                "regex": "BENEFICIARY:(.*?)AC/\\d* .*(?=[A-Z]{3,}?:|$)",
                "flag":"",
                "retain":"y",
                "map":"n"
            },
            {
                "key": "{Description}",
                "field": "originator",
                "regex": "ORIGINATOR:(.*?)AC/\\d* .*(?=[A-Z]{3,}?:|$)",
                "flag":"",
                "retain":"y",
                "map":"n"
            },
            {
                "key": "{Description}",
                "field": "OBI",
                "regex": "OBI:(.*?)(?=[A-Z]{3,}?:|$)",
                "flag":"",
                "retain":"y",
                "map":"n"
            },
            {
                "key": "{Description}",
                "field": "RFB",
                "regex": "RFB:(.*?)(?=[A-Z]{3,}?:|$)",
                "flag":"",
                "retain":"y",
                "map":"n"
            },
            {
                "key": "{Description}",
                "field": "ABA",
                "regex": "ABA:(.*?)(?=[A-Z]{3,}?:|$)",
                "flag":"",
                "retain":"y",
                "map":"n"
            },
            {
                "key": "{Description}",
                "field": "BBI",
                "regex": "BBI:(.*?)(?=[A-Z]{3,}?:|$)",
                "flag":"",
                "retain":"y",
                "map":"n"
            },
            {
                "key": "{Description}",
                "field": "BENEBNK",
                "regex": "BENEBNK:(.*?)(?=[A-Z]{3,}?:|$)",
                "flag":"",
                "retain":"y",
                "map":"n"
            },
            {
                "key": "{Description}",
                "field": "IBK",
                "regex": "IBK:(.*?)(?=[A-Z]{3,}?:|$)",
                "flag":"",
                "retain":"y",
                "map":"n"
            },
            {
                "key": "{Description}",
                "field": "RATE",
                "regex": "RATE:(.*?)(?=[A-Z]{3,}?:|$)",
                "flag":"",
                "retain":"y",
                "map":"n"
            },
            {
                "key": "{Description}",
                "field": "RECVBNK",
                "regex": "RECVBNK:(.*?)(?=[A-Z]{3,}?:|$)",
                "flag":"",
                "retain":"y",
                "map":"n"
            }
        ],
        "function":"extract",
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
            "defn": [
                {
                    "key": "{AccountName}",
                    "field": "acctn",
                    "regex": "(.*)",
                    "retain": "n",
                    "map":"y"
                },
                {
                    "key": "{Transaction}",
                    "field": "trans",
                    "regex": "(.*)",
                    "retain": "n",
                    "map":"y"
                },
                {
                    "key": "{Description}",
                    "field": "ini",
                    "regex": "([\\w].*?)(?=$| -|\\s[0-9].*?|\\s[\\w/]+?:)",
                    "retain": "y",
                    "map":"y"
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
            "defn": [
                {
                    "key": "{Description}",
                    "field": "ini",
                    "regex": "([\\w].*?)(?=$| -|\\s[0-9].*?|\\s[\\w/]+?:)",
                    "retain": "y",
                    "map":"y"
                },
                {
                    "key": "{Description}",
                    "field": "curr1",
                    "regex": ".*(DEBIT|CREDIT).*(USD|CAD).*(?=DEBIT|CREDIT).*(?=USD|CAD).*",
                    "retain": "y",
                    "map":"y"
                },
                {
                    "key": "{Description}",
                    "field": "curr2",
                    "regex": ".*(?=DEBIT|CREDIT).*(?=USD|CAD).*(DEBIT|CREDIT).*(USD|CAD).*",
                    "retain": "y",
                    "map":"y"
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
            "defn": [
                {
                    "key": "{Description}",
                    "field": "checkn",
                    "regex": "[^0-9]*([0-9]*)\\s|$",
                    "retain": "y",
                    "map":"n"
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

  
UPDATE tps.map_rm  
SET regex = 
    $j$
    {
        "name":"ADP Codes",
        "description":"link to adp code definitions",
        "defn": [
            {
                "key": "{gl_descr}",
                "field": "gl_descr",
                "regex": ".*",
                "flag":"",
                "retain":"n",
                "map":"y"
            },
            {
                "key": "{prim_offset}",
                "field": "prim_offset",
                "regex": ".*",
                "flag":"",
                "retain":"n",
                "map":"y"
            },
            {
                "key": "{pay_date}",
                "field": "pay_month",
                "regex": ".{1,4}",
                "flag":"",
                "retain":"y",
                "map":"n"
            }
        ],
        "function":"extract",
        "where": [
            {
            }
        ]
    }
    $j$::jsonb
WHERE 
    target = 'ADP Codes';