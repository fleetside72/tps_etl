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