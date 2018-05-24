SELECT * FROM TPS.SRCE_SET($${
    "name":"dcard",
    "source":"client_file",
    "loading_function":"csv",
    "constraint":[
        "{Trans. Date}",
        "{Post Date}"
    ],
    "schemas":{
        "default":[
            {
                "path":"{Trans. Date}",
                "type":"date",
                "column_name":"Trans. Date"
            },
            {
                "path":"{Post Date}",
                "type":"date",
                "column_name":"Post Date"
            },
            {
                "path":"{Description}",
                "type":"text",
                "column_name":"Description"
            },
            {
                "path":"{Amount}",
                "type":"numeric",
                "column_name":"Amount"
            },
            {
                "path":"{Category}",
                "type":"text",
                "column_name":"Category"
            }
        ],
        "version2":[]
    }
}$$::JSONB)