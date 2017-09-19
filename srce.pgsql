SELECT
jsonb_pretty(
$$
{
    "name": "GOOGDM",
    "type": "json_csv",
    "schema": {
        "rows": [
            {
                "elements": [
                    {
                        "status": "text",
                        "distance": {
                            "text": "text",
                            "value": "numeric"
                        },
                        "duration": {
                            "text": "text",
                            "value": "value"
                       }
                    }
                ]
            }
        ],
        "status": "text",
        "origin_addresses": [
            "text"
        ],
        "destination_addresses": [
            "text"
        ]
    },
    "unique_constraint": {
        "type": "key",
        "fields": [
            "{origin_adresses,0}",
            "{destination_adresses,0}"
        ]
    }
}
$$::jsonb
)