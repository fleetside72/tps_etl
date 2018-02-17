map definition
----------------------------------------------------------

    {
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
            {
            }
        ],
        "function": "extract",
        "description": "pull first 20 characters from description for mapping"
    }

assign values to the result of the regex
-----------------------------------------------------


| retval                          | map                                                                                 |
| ------------------------------- | ----------------------------------------------------------------------------------- |
| {"f20": "BIG LOTS #00453 STOW"} | {"party": "Big Lots", "reason": "Home Supplies"}                                    |
| {"f20": "1794MOTHERHOOD #1794"} | {"party": "Motherhood", "reason": "Clothes"}                                        |
| {"f20": "3 PALMS HUDSON OH"}    | {"city": "Hudson", "party": "3 Palms", "reason": "Restaurante", "province": "Ohio"} |
| {"f20": "36241 7-ELEVEN STOW "} | {"city": "Stow", "party": "7-Eleven", "reason": "Gasoline", "province": "Ohio"}     |
| {"f20": "7-ELEVEN 36241 STOW "} | {"city": "Stow", "party": "7-Eleven", "reason": "Gasoline", "province": "Ohio"}     |
| {"f20": "98626 - 200 PUBLIC S"} | {"party": "Public Square Parking Garage", "reason": "Recreation"}                   |
| {"f20": "ACE HARDWARE HUDSON "} | {"party": "Ace Hardware", "reason": "Home Maintenance"}                             |
| {"f20": "ACH CAFE AND STARBUC"} | {"party": "Starbucks", "reason": "Restaurante"}                                     |
