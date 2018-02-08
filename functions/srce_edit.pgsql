
CREATE OR REPLACE FUNCTION tps.srce_set(_name text, _defn jsonb) RETURNS jsonb
AS $f$
BEGIN

/*
1. determine if insert or update
2. if update, determine if conflicts exists
3. do merge
*/


END;
$f$
LANGUAGE plpgsql
