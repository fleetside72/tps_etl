Generic Data Transformation Tool
----------------------------------------------

The goal is to:
1. house external data and prevent duplication on insert
2. facilitate regular exression operations to extract meaningful data
3. be able to reference it from outside sources (no action required) and maintain reference to original data


It is well suited for data from outside systems that 
* requires complex transformation (parsing and mapping)
* original data is retained for reference

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
