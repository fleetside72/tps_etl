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
        ]
    },
    "constraint": [
        "{doc,origin_addresses}",
        "{doc,destination_addresses}"
    ]
}
    $$
) r(x);