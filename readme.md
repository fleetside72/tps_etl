Generic Data Transformation Tool
----------------------------------------------

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
* Source Definitions (Maint/Inquire)

    * display a list of existing sources with display detials/edit options
    * create new option
    * underlying function is `tps.srce_set(_name text, _defn jsonb)`

* Regex Instructions (Maint/Inquire)

    * display a list of existing instruction sets with display details/edit options
    * create new option
    * underlying function is `tps.srce_map_def_set(_srce text, _map text, _defn jsonb, _seq int)` which takes a source "code" and a json

* Cross Reference List (Maint/Inquire)

    * first step is to populate a list of values returned from the instructions (choose all or unmapped) `tps.report_unmapped(_srce text)`
    * the list of rows facilitates additional named column(s) to be added which are used to assign values anytime the result occurs
    * function to set the values of the cross reference `tps.srce_map_val_set_multi(_maps jsonb)`

* Run Import

    * underlying function is `tps.srce_import(_path text, _srce text)`
