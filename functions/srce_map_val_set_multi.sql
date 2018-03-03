DROP FUNCTION tps.srce_map_val_set_multi;
CREATE OR REPLACE FUNCTION tps.srce_map_val_set_multi(_maps jsonb) RETURNS JSONB
LANGUAGE plpgsql
AS $f$

DECLARE
    _message jsonb;
    _MESSAGE_TEXT text;
    _PG_EXCEPTION_DETAIL text;
    _PG_EXCEPTION_HINT text;

BEGIN


	WITH 
	-----------expand the json into a table------------------------------------------------------------------------------
	t AS (
		SELECT 
			jtr.*
		FROM
			jsonb_array_elements(_maps) ae(v)
			JOIN LATERAL jsonb_to_record(ae.v) AS jtr(source text, map text, ret_val jsonb, mapped jsonb) ON TRUE
	)
	-----------do merge---------------------------------------------------------------------------------------------------
	INSERT INTO
		tps.map_rv
	SELECT
		t."source"
		,t."map"
		,t.ret_val
		,t.mapped
	FROM
		t
	ON CONFLICT ON CONSTRAINT map_rv_pk DO UPDATE SET
		map = excluded.map;

	-------return message--------------------------------------------------------------------------------------------------
	 _message:= jsonb_build_object('status','complete');
    RETURN _message;

EXCEPTION WHEN OTHERS THEN

    GET STACKED DIAGNOSTICS 
            _MESSAGE_TEXT = MESSAGE_TEXT,
            _PG_EXCEPTION_DETAIL = PG_EXCEPTION_DETAIL,
            _PG_EXCEPTION_HINT = PG_EXCEPTION_HINT;
    _message:= 
        ($$
            {
                "status":"fail",
                "message":"error setting map value"
            }
        $$::jsonb)
        ||jsonb_build_object('message_text',_MESSAGE_TEXT)
        ||jsonb_build_object('pg_exception_detail',_PG_EXCEPTION_DETAIL);

        RETURN _message;

END;
$f$