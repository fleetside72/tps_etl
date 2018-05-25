SELECT
    *
FROM
    tps.srce_import(
        'DMAPI'
        ,$$
        [{
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
        }]
        $$::JSONB
    )