DELETE FROM tps.map_rm;
INSERT INTO
tps.map_rm
SELECT *
FROM
(VALUES 
    ('DCARD', 'First 20', 
    $j$
    {
        "defn": [
            {
                "key": "{Description}",
                "field": "f20",
                "regex": ".{1,20}"
                ,"retain":"y"
            }
        ],
        "where": [
            {
            }
        ]
    }
    $j$::jsonb
    , 2)
    ,('HUNT', 'First 20', 
    $j$
    {
        "defn": [
            {
                "key": "{Description}",
                "field": "f20",
                "regex": ".{1,20}"
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
) x