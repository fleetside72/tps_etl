
sample data
------------------------------------


| Trans. Date | Post Date | Description                                    | Amount | Category             |
| ----------- | --------- | ---------------------------------------------- | ------ | -------------------- |
| 1/2/2018    | 1/2/2018  | GOOGLE *YOUTUBE VIDEOS G.CO/HELPPAY#CAP0H07TXV | 4.26   | Services             |
| 1/2/2018    | 1/2/2018  | MICROSOFT *ONEDRIVE 800-642-7676 WA            | 4.26   | Services             |
| 1/3/2018    | 1/3/2018  | CLE CLINIC PT PMTS 216-445-6249 OHAK2C57F2F0B3 | 200    | Medical Services     |
| 1/4/2018    | 1/4/2018  | AT&T *PAYMENT 800-288-2020 TX                  | 57.14  | Services             |
| 1/4/2018    | 1/7/2018  | WWW.KOHLS.COM #0873 MIDDLETOWN OH              | -7.9   | Payments and Credits |
| 1/5/2018    | 1/7/2018  | PIZZA HUT 007946 STOW OH                       | 9.24   | Restaurants          |
| 1/5/2018    | 1/7/2018  | SUBWAY 00044289255 STOW OH                     | 10.25  | Restaurants          |
| 1/6/2018    | 1/7/2018  | ACME NO. 17 STOW OH                            | 103.98 | Supermarkets         |
| 1/6/2018    | 1/7/2018  | DISCOUNT DRUG MART 32 STOW OH                  | 1.69   | Merchandise          |
| 1/6/2018    | 1/7/2018  | DISCOUNT DRUG MART 32 STOW OH                  | 2.19   | Merchandise          |
| 1/9/2018    | 1/9/2018  | CIRCLE K 05416 STOW OH00947R                   | 3.94   | Gasoline             |
| 1/9/2018    | 1/9/2018  | CIRCLE K 05416 STOW OH00915R                   | 52.99  | Gasoline             |


screen
------------------------------------

```
     +---------------+
Name:|DCARD          |
     +---------------+
     +---------------+
Desc:|Discover Card  |
     +---------------+

     Col Name              Data Type              Unique Constraint Flag
+-----------------------------------------------------------------------+

    +-----------------+   +-------------------+  +---+
    |Trans. Date      |   |date            |\/|  | X |
    +-----------------+   +-------------------+  +---+
    +-----------------+   +-------------------+  +---+
    |Post Date        |   |date            |\/|  | X |
    +-----------------+   +-------------------+  +---+
    +-----------------+   +-------------------+  +---+
    |Description      |   |text            |\/|  | X |
    +-----------------+   +-------------------+  +---+
    +-----------------+   +-------------------+  +---+
    |Amount           |   |numeric         |\/|  |   |
    +-----------------+   +-------------------+  +---+
    +-----------------+   +-------------------+  +---+
    |Category         |   |text            |\/|  |   |
    +-----------------+   +-------------------+  +---+

    Somehow be able to add more
```


screen builds json
--------------------------------------

    {
        "name": "DCARD",
        "type": "csv",
        "schema": [
            {
                "key": "Trans. Date",
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
            },
            {
                "key": "Category",
                "type": "text"
            }
        ],
        "unique_constraint": {
            "type": "key",
            "fields": [
                "{Post Date}",
                "{Trans. Date}",
                "{Description}"
            ]
        }
    }

SQL
---------------------------------------
SELECT 
    jsonb_pretty(r.x) 
FROM
    tps.srce_set(
    'DCARD',
    $$
    {
        "name": "DCARD",
        "type": "csv",
        "schema": [
            {
                "key": "Trans. Date",
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
            },
            {
                "key": "Category",
                "type": "text"
            }
        ],
        "unique_constraint": {
            "type": "key",
            "fields": [
                "{Post Date}",
                "{Trans. Date}",
                "{Description}"
            ]
        }
    }
    $$
) r(x)

backend handles SQL
-----------------------------------

`sql = "SELECT tps.srce_set(_name, _json)"`

`json_return_value = connection.execute(sql)`

handle json_return_value
* insert: notify and clear? update list of sources on screen?
* could not insert: print reason from json