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