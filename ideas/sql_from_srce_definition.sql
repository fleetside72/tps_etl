WITH s AS (
select 
$${
    "name":"DMAPI",
    "source":"client_file",
    "loading_function":"csv",
    "constraint":[
        "{doc}"
    ],
    "schema_type":"JSONB_POPULATE",
    "table_schema":[
        {
            "path":"{doc,origin_addresses,0}",
            "type":"text",
            "column_name":"origin_address"
        },
        {
            "path":"{doc,destination_addresses,0}",
            "type":"text",
            "column_name":"origin_address"
        },
        {
            "path":"{doc,status}",
            "type":"text",
            "column_name":"status"
        },
        {
            "path":"{doc,rows,0,elements,0,distance,value}",
            "type":"numeric",
            "column_name":"distance"
        },
        {
            "path":"{doc,rows,0,elements,0,duration,value}",
            "type":"numeric",
            "column_name":"duration"
        }
    ]
}$$::jsonb->'table_schema' defn
)
,ext AS (
SELECT 
    ae.v->>'path' path
    ,ae.v->>'type' dtype
    ,ae.v->>'column_name' column_name
FROM 
    s
    LEFT JOIN LATERAL JSONB_ARRAY_ELEMENTS(s.defn) ae(v) ON TRUE
)
SELECT
    'SELECT '||string_agg('(rec#>>('''||path||'''::text[]))::'||dtype||' AS '||column_name,', ')||' FROM tps.trans WHERE srce = ''DMAPI'''
FROM
    ext