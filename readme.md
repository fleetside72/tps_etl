Generic Data Transformation Tool
=======================================================

The goal is to:
1. house external data and prevent duplication on insert
2. facilitate regular exression operations to extract meaningful data
3. be able to reference it from outside sources (no action required) and maintain reference to original data


It is well suited for data from outside systems that 
* requires complex transformation (parsing and mapping)
* original data is retained for reference
* don't feel like writing a map-reduce

use cases:
* on-going bank feeds
* jumbled product lists
* storing api results


The data is converted to json by the importing program and inserted to the database.
Regex expressions are applied to specified json components and the results can be mapped to other values.


Major Interactions
------------------------

* Source Definitions (Maint/Inquire)
* Regex Instructions (Maint/Inquire)
* Cross Reference List (Maint/Inquire)
* Run Import (Run Job)



### Interaction Details
* _Source Definitions (Maint/Inquire)_

    * display a list of existing sources with display detials/edit options
    * create new option
    * underlying function is `tps.srce_set(_name text, _defn jsonb)`

    * the current definition of a source includes data based on bad presumptions:
        * how to load from a csv file using `COPY`
        * setup a Postgres type to reflect the associated columns (if applicable)
        

* _Regex Instructions (Maint/Inquire)_

    * display a list of existing instruction sets with display details/edit options
    * create new option
    * underlying function is `tps.srce_map_def_set(_srce text, _map text, _defn jsonb, _seq int)` which takes a source "code" and a json

* _Cross Reference List (Maint/Inquire)_

    * first step is to populate a list of values returned from the instructions (choose all or unmapped) `tps.report_unmapped(_srce text)`
    * the list of rows facilitates additional named column(s) to be added which are used to assign values anytime the result occurs
    * function to set the values of the cross reference `tps.srce_map_val_set_multi(_maps jsonb)`

* _Run Import_

    * underlying function is `tps.srce_import(_path text, _srce text)`



source definition
----------------------------------------------------------------------

* **load data**
    * the brwosers role is to extract the contents of a file and send them as a post body to the backend for processing under target function `based on srce defintion`
        * the backend builds a json array of all the rows to be added and sends as an argument to a database insert function
            * build constraint key `based on srce definition`
            * handle violations
            * increment global key list (this may not be possible depending on if a json with variable length arrays can be traversed)
            * build an import log
            * run maps (as opposed to relying on trigger)
* **read data**
    * top level key to table as type?
    * view that `uses the source definiton` to extrapolate a table?
    * a materialized table is built `based on the source definition` and any addtional regex?
        * add regex = alter table add column with historic updates?
        * no primary key?
        * every document must work out to one row

{
    "name":"sample_name",
    "source":"client_file",
    "loading_function":"csv"
    "constrain":[
        "{date}",
        "{level1,item3,field}"
    ],
    "table_schema":[
        {
            "top_level_key":"column"name",
            "type":"numeric"
        },
        {
            "top_level_key":"column"name",
            "type":"numeric"
        }
    ]
}

