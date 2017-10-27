/*
DELETE FROM tps.map_rm  where target = 'Strip Amount Commas';
INSERT INTO
tps.map_rm
SELECT *
FROM
(VALUES 
    ('PNCC', 'Strip Amount Commas', 
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
    , 1)
) x;
*/

DELETE FROM tps.map_rm  where target = 'Parse ACH';

INSERT INTO
tps.map_rm
SELECT *
FROM
(VALUES 
    ('PNCC', 'Parse ACH', 
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
    , 2)
) x;

/*

DELETE FROM tps.map_rm  where target = 'Parse Wires';
INSERT INTO
tps.map_rm
SELECT *
FROM
(VALUES 
    ('PNCC', 'Parse Wires', 
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
    , 2)
) x;