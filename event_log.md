event log

        collection of dissimilar items
        -> trigger based on insert adds to GL
            -> gl adds to balance based on GL trigger
                ? how is fiscal period determined


log gl format
* the gl array is an array of object
    * each gl line is initially a full json object
    * extract demanded fields (account, amount) and delete from the json but retain the rest as the supporting items