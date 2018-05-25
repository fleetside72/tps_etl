DO 
$f$
DECLARE
    _t text;
    _c text;
    _log_info jsonb;
    _log_id text;
    _cnt numeric;
    _message jsonb;
    _recs jsonb;
    _srce text;
    _defn jsonb;
    _MESSAGE_TEXT text;
    _PG_EXCEPTION_DETAIL text;
    _PG_EXCEPTION_HINT text;

BEGIN

    _srce := 'DMAPI';
    _recs:= $${"id":1,"doc":{"rows":[{"elements":[{"status":"OK","distance":{"text":"225 mi","value":361940},"duration":{"text":"3 hours 50 mins","value":13812}}]}],"status":"OK","origin_addresses":["Washington, DC, USA"],"destination_addresses":["New York, NY, USA"]}}$$::jsonb;

----------------------------------------------------test if source exists----------------------------------------------------------------------------------

    SELECT
        defn
    INTO
        _defn
    FROM
        tps.srce    
    WHERE
        srce = _srce;

    IF _defn IS NULL THEN
        _message:= 
        format(
            $$
                {
                    "status":"fail",
                    "message":"source %L does not exists"
                }
            $$,
            _srce
        )::jsonb;
        RAISE NOTICE '%s', _message;
    END IF;

    -------------unwrap the json record and apply the path(s) of the constraint to build a constraint key per record-----------------------------------------------------------------------------------

    WITH
    pending_list AS (
        SELECT
            _srce srce
            ,j.rec
            ,j.id
            --aggregate back to the record since multiple paths may be listed in the constraint
            --it is unclear why the "->>0" is required to correctly extract the text array from the jsonb
            ,tps.jsonb_concat_obj(
                jsonb_build_object(
                    --the new json key is the path itself
                    cons.path->>0
                    ,j.rec#>((cons.path->>0)::text[])
                ) 
            ) json_key
        FROM
            jsonb_array_elements(_recs) WITH ORDINALITY j(rec,id)
            JOIN LATERAL jsonb_array_elements(_defn->'constraint') WITH ORDINALITY cons(path, seq)  ON TRUE
        GROUP BY
            j.rec
            ,j.id
    )

    -----------create a unique list of keys from staged rows------------------------------------------------------------------------------------------

    , pending_keys AS (
        SELECT DISTINCT
            json_key
        FROM 
            pending_list
    )

    -----------list of keys already loaded to tps-----------------------------------------------------------------------------------------------------

    , matched_keys AS (
        SELECT DISTINCT
            k.json_key
        FROM
            pending_keys k
            INNER JOIN tps.trans t ON
                t.ic = k.json_key
    )

    -----------return unique keys that are not already in tps.trans-----------------------------------------------------------------------------------

    , unmatched_keys AS (
    SELECT
        json_key
    FROM
        pending_keys

    EXCEPT

    SELECT
        json_key
    FROM
        matched_keys
    )

    --------build log record-------------------+------------------------------------------------------------------------------------------------

    , logged AS (
    INSERT INTO
        tps.trans_log (info)
    SELECT
        JSONB_BUILD_OBJECT('time_stamp',CURRENT_TIMESTAMP)
        ||JSONB_BUILD_OBJECT('srce',_srce)
        --||JSONB_BUILD_OBJECT('path',_path)
        ||JSONB_BUILD_OBJECT('not_inserted',
            (
                SELECT 
                    jsonb_agg(json_key)
                FROM
                    matched_keys
            )
        )
        ||JSONB_BUILD_OBJECT('inserted',
            (
                SELECT 
                    jsonb_agg(json_key)
                FROM
                    unmatched_keys
            )
        )
    RETURNING *
    )

    -----------insert pending rows that have key with no trans match-----------------------------------------------------------------------------------
    --need to look into mapping the transactions prior to loading

    , inserted AS (
        INSERT INTO
            tps.trans (srce, rec, ic, logid)
        SELECT
            pl.srce
            ,pl.rec
            ,pl.json_key
            ,logged.id
        FROM 
            pending_list pl
            INNER JOIN unmatched_keys u ON
                u.json_key = pl.json_key
            CROSS JOIN logged
        ORDER BY
            pl.id ASC
        ----this conflict is only if an exact duplicate rec json happens, which will be rejected
        ----therefore, records may not be inserted due to ay matches with certain json fields, or if the entire json is a duplicate, reason is not specified
        RETURNING *
    )

    SELECT
        id
        ,info
    INTO
        _log_id
        ,_log_info
    FROM
        logged;

    --RAISE NOTICE 'import logged under id# %, info: %', _log_id, _log_info;

    _message:= 
    (
        $$
            {
            "status":"complete"
            }
        $$::jsonb
    )||jsonb_build_object('details',_log_info);

    RAISE NOTICE '%s', _message;

END;
$f$
LANGUAGE plpgsql

