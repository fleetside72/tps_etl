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

DELETE FROM tps.map_rm  where target = 'Parse Descr';
INSERT INTO
tps.map_rm
SELECT *
FROM
(VALUES 
    ('PNCC', 'Parse Descr', 
    $j$
    {
        "name":"Parse Descr",
        "description":"parse the description based on at least three capital letters followed by a comma until another set of at lesat 3 capital letters and a comma is encountered",
        "defn": [
            {
                "key": "{Description}",
                "field": "dparse",
                "regex": "([A-Z]{3,}?:)(.*)(?=[A-Z]{3,}?:|$)",
                "flag":"g",
                "retain":"y"
            }
        ],
        "function":"extract",
        "map":"no",
        "where": [
            {
            }
        ]
    }
    $j$::jsonb
    , 2)
) x;


DELETE FROM tps.map_rm  where target = 'Extract OBI';
INSERT INTO
tps.map_rm
SELECT *
FROM
(VALUES 
    ('PNCC', 'Extract OBI', 
    $j$
    {
        "name":"Extract OBI",
        "description":"pull out whatever follows OBI in the description until atleast 3 capital letters followed by a colon are encountered",
        "defn": [
            {
                "key": "{Description}",
                "field": "obi",
                "regex": "OBI:(.*?)(?=[A-Z]{3,}?:|$)",
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
                "Transaction":"Money Transfer CR-Other"
            },
            {
                "Transaction":"Intl Money Transfer Debits"
            },
            {
                "Transaction":"Money Transfer DB - Other"
            },
            {
                "Transaction":"Money Transfer CR-Wire"
            }
        ]
    }
    $j$::jsonb
    , 2)
) x;
*/
DELETE FROM tps.map_rm  where target = 'Extract RFB';
INSERT INTO
tps.map_rm
SELECT *
FROM
(VALUES 
    ('PNCC', 'Extract RFB', 
    $j$
    {
        "name":"Extract RFB",
        "description":"pull out whatever follows RFB in the description until atleast 3 capital letters followed by a colon are encountered",
        "defn": [
            {
                "key": "{Description}",
                "field": "rfb",
                "regex": "RFB:(.*?)(?=[A-Z]{3,}?:|$)",
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
                "Transaction":"Money Transfer CR-Other"
            },
            {
                "Transaction":"Intl Money Transfer Debits"
            },
            {
                "Transaction":"Money Transfer DB - Other"
            },
            {
                "Transaction":"Money Transfer CR-Wire"
            }
        ]
    }
    $j$::jsonb
    , 2)
) x;