delete from tps.trans where srce = 'DMAPI';

----------------------set definition-----------------
SELECT 
    jsonb_pretty(r.x) 
FROM
    tps.srce_set(
    $$
{
    "name": "DMAPI",
    "type": "csv",
    "schemas": {
        "default": [
            {
                "path": "{doc,origin_addresses,0}",
                "type": "text",
                "column_name": "origin_address"
            },
            {
                "path": "{doc,destination_addresses,0}",
                "type": "text",
                "column_name": "destination_address"
            },
            {
                "path": "{doc,rows,0,elements,0,distance,value}",
                "type": "numeric",
                "column_name": "distince"
            },
            {
                "path": "{doc,rows,0,elements,0,duration,value}",
                "type": "numeric",
                "column_name": "duration"
            }
        ],
        "constraint": [
            "{doc}"
        ]
    }
}
    $$
) r(x);
--------------------------build a csv file---------------------

copy
(
select
$$
{
    "id": 1,
    "doc": {
        "rows": [
            {
                "elements": [
                    {
                        "status": "OK",
                        "distance": {
                            "text": "225 mi",
                            "value": 361940
                        },
                        "duration": {
                            "text": "3 hours 50 mins",
                            "value": 13812
                        }
                    }
                ]
            }
        ],
        "status": "OK",
        "origin_addresses": [
            "Washington, DC, USA"
        ],
        "destination_addresses": [
            "New York, NY, USA"
        ]
    }
}
$$::JSONB DOC
)
to 'C:\users\fleet\downloads\testj.csv' with (FORMAT CSV, QUOTE '"', HEADER true);

---------------------------------insert rows----------------------------------------

SELECT
    *
FROM
    tps.srce_import('C:\users\fleet\downloads\testj.csv','DMAPI') x(message);

    
select id, srce, jsonb_pretty(rec) from tps.trans where srce = 'DMAPI';