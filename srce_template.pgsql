insert into tps.srce
SELECT
'CAMZ',
$$
{
    "name": "CAMZ",
    "description":"Chase Amazon Credit Card",
    "type": "csv",
    "schema": [
        {
            "key": "Type",
            "type": "text"
        },
        {
            "key": "Trans Date",
            "type": "date"
        },
        {
            "key": "Post Date",
            "type": "date"
        },
        {
            "key": "Description",
            "type": "text"
        },
        {
            "key": "Amount",
            "type": "numeric"
        }
    ],
    "unique_constraint": {
        "type": "key",
        "fields": [
            "{Trans Date}"
            ,"{Post Date}"
        ]
    }
}
$$::JSONB