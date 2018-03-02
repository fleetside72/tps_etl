delete from tps.trans where srce = 'DMAPI';

----------------------set definition-----------------
SELECT 
    jsonb_pretty(r.x) 
FROM
    tps.srce_set(
    'DMAPI',
    $$
    {
        "name": "DMAPI",
        "type": "csv",
        "schema": [
            {
                "key": "doc",
                "type": "jsonb"
            }
        ],
        "unique_constraint": {
            "type": "key",
            "fields": [
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
   "destination_addresses" : [ "New York, NY, USA" ],
   "origin_addresses" : [ "Washington, DC, USA" ],
   "rows" : [
      {
         "elements" : [
            {
               "distance" : {
                  "text" : "225 mi",
                  "value" : 361940
               },
               "duration" : {
                  "text" : "3 hours 50 mins",
                  "value" : 13812
               },
               "status" : "OK"
            }
         ]
      }
   ],
   "status" : "OK"
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