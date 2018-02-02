Overview
----------------------------------------------


```
                        +--------------+
                        |csv data      |
                        +-----+--------+
                              |
                              |
                              v
+----web ui----+        +----func+----+            +---table----+
|import screen +------> |srce.sql     +----------> |tps.srce    | <-------------------+
+--------------+        +-------------+            +------------+                     |
                        |p1:srce      |                                               |
                        |p2:file path |                                               |
+-----web ui---+        +-------------+            +----table---+                     |
|create map    |                                   |tps.map_rm  |                  +--+--db proc-----+
|profile       +---------------------------------> |            |                  |update tps.trans |
+------+-------+                                   +-----+------+                  |column allj to   |
       |                                                 ^                         |contain map data |
       |                                                 |                         +--+--------------+
       v                                                foreign key                   ^
+----web ui+----+                                        |                            |
|assign maps    |                                        +                            |
|for return     |                                  +---table----+                     |
+values         +--------------------------------> |tps.map_rv  |                     |
+---------------+                                  |            +---------------------+
                                                   +------------+

```

The goal is to:
1. house external data and prevent duplication on insert
2. apply mappings to the data to make it meaningful
3. be able to reference it from outside sources (no action required)

There are 5 tables
* tps.srce : definition of source
* tps.trans : actual data
* tps.trans_log : log of inserts
* tps.map_rm : map profile
* tps.map_rv : profile associated values

# tps.srce schema
    {
        "name": "WMPD",
        "descr": "Williams Paid File",
        "type":"csv",
        "schema": [
            {
                "key": "Carrier",
                "type": "text"
            },
            {
                "key": "Pd Amt",
                "type": "numeric"
            },
            {
                "key": "Pay Dt",
                "type": "date"
            }
        ],
        "unique_constraint": {
            "fields":[
                "{Pay Dt}",
                "{Carrier}" 
            ]
        }
    }

# tps.map_rm schema
    {
        "name":"Strip Amount Commas",
        "description":"the Amount field comes from PNC with commas embeded so it cannot be cast to numeric",
        "defn": [
            {
                "key": "{Amount}",        /*this is a Postgres text array stored in json*/
                "field": "amount",        /*key name assigned to result of regex/* 
                "regex": ",",             /*regular expression/*
                "flag":"g",
                "retain":"y",
                "map":"n"
            }
        ],
        "function":"replace",
        "where": [
            {
            }
        ]
    }












Notes
======================================

pull various static files into postgres and do basic transformation without losing the original document
or getting into custom code for each scenario

the is an in-between for an foreign data wrapper & custom programming

## Storage
all records are jsonb
applied mappings are in associated jsonb documents

## Import
`COPY` function utilized

## Mappings
1. regular expressions are used to extract pieces of the json objects
2. the results of the regular expressions are bumped up against a list of basic mappings and written to an associated jsonb document

each regex expression within a targeted pattern can be set to map or not. then the mapping items should be joined to map_rv with an `=` as opposed to `@>` to avoid duplication of rows


## Transformation tools
* `COPY`
* `regexp_matches()`

## Difficulties
Non standard file formats will require additional logic
example: PNC loan balance and collateral CSV files
1. External:    Anything not in CSV should be converted external to Postgres and then imported as CSV
2. Direct:      Outside logic can be setup to push new records to tps.trans direct from non-csv fornmated sources or fdw sources

## Interface
maybe start out in excel until it gets firmed up
* list existing mappings
    * apply mappings to see what results come back
* experiment with new mappings