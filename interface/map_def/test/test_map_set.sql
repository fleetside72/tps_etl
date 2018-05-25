SELECT 
    * 
FROM 
    tps.srce_map_def_set(
        $$
            {
                "srce":"dcard",
                "sequence":1,
                "defn": [
                    {
                        "key": "{Description}",
                        "map": "y",
                        "flag": "",
                        "field": "f20",
                        "regex": ".{1,20}",
                        "retain": "y"
                    }
                ],
                "name": "First 20",
                "where": [
                    {}
                ],
                "function": "extract",
                "description": "pull first 20 characters from description for mapping"
            }
        $$
    )