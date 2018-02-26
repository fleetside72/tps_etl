

regular expression screen
---------------------------------------------

```
                     +------------------------+----+
          source     | DCARD                  | \/ |
                     +-----------------------------+
                     +-----------------------------+
          new name   |First 20                     |
                     +-----------------------------+
                     +-----------------------------+
          function   | extract(replace)       | \/ |
                     +------------------------+----+



         (each block is a regex, all blocks are concatenated into an array and linked to mapped ^alues)

          first 20 characters
         +----------------------------------+

                   +----------------------------------------------------------------------------------------------------+
            +      |                      +-----------------------------+                                               |
            |      |            Field Name| Description             | \/|  expressed as jsonb path "{Description}")     |
        +-------+  |                      +-----------------------------+                                               |
            |      |                      +-------------------------+                                                   |
            +      |label of return ^alue |f20                      |                                                   |
                   |                      +-------------------------+                                                   |
                   |                      +-------------------------+                                                   |
                   |  regular expression  |.{1,20}                  |   supply test run ^alues                          |
                   |                      +-------------------------+                                                   |
                   |                      +-------------------------+                                                   |
                   |          replace wit |                         |                                                   |
                   |                      +-------------------------+                                                   |
                   |                      +---+                                                                         |
                   |           Map Results|Y/N|                                                                         |
                   |                      +---+                                                                         |
                   |                      +---+                                                                         |
                   |      Find All Matches| g |                                                                         |
                   |                      +---+                                                                         |
                   |       filter(s)                                                                                    |
                   |    +-------------------------------------------+                                                   |
                   |      +----------------+ +----------------+                                                         |
                   |      |Category        | |Restaurantes    |                                                         |
                   |      +----------------+ +----------------+                                                         |
                   |      +----------------+ +----------------+                                                         |
                   |      |Category        | |Services        |                                                         |
                   |      +----------------+ +----------------+                                                         |
                   |                                                                                                    |
                   +----------------------------------------------------------------------------------------------------+

```


map definition
----------------------------------------------------------

    {
        "defn": [
            {
                "key": "{Description}",
                "map": "y",
                "flag": "g",
                "field": "f20",
                "regex": ".{1,20}",
                "retain": "y"
            }
        ],
        "name": "First 20",
        "where": [
            {"Category":"Restaurantes"},
            {"Category":"Services"}
        ],
        "function": "extract",
        "description": "pull first 20 characters from description for mapping"
    }

SQL
---------------------------------------------
INSERT INTO
    tps.map_rm
SELECT
    'DCARD',
    'First 20',
    $$    {
        "defn": [
            {
                "key": "{Description}",
                "map": "y",
                "flag": "g",
                "field": "f20",
                "regex": ".{1,20}",
                "retain": "y"
            }
        ],
        "name": "First 20",
        "where": [
            {"Category":"Restaurantes"},
            {"Category":"Services"}
        ],
        "function": "extract",
        "description": "pull first 20 characters from description for mapping"
    } $$::jsonb,
    1


assign new key/values to the results of the regular expression, and then back to the underlying row it came from
-----------------------------------------------------------------------------------------------------------------

| returned from expression        | party             | reason        | city   | provice |     |
| ------------------------------- | ----------------- | ------------- | ------ | ------- | --- |
| {"f20": "BIG LOTS #00453 STOW"} | Big Lots          | Home Supplies | Stow   | Ohio    |     |
| {"f20": "1794MOTHERHOOD #1794"} | Motherhood        | Clothes       |        |         |     |
| {"f20": "3 PALMS HUDSON OH"}    | 3 Palms           | Restaurantes  | Hudson | Ohio    |     |
| {"f20": "36241 7-ELEVEN STOW "} | 7-Eleven          | Gasoline      | Stow   | Ohio    |     |
| {"f20": "7-ELEVEN 36241 STOW "} | 7-Eleven          | Gasoline      | Stow   | Ohio    |     |
| {"f20": "98626 - 200 PUBLIC S"} | Public Sq Parking | Recreation    |        |         |     |
| {"f20": "ACE HARDWARE HUDSON "} | Ace Hardware      | Home Maint    | Hudson | Ohio    |     |
| {"f20": "ACH CAFE AND STARBUC"} | Starbucks         | Restaurantes  |        |         |     |