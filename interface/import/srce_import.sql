DROP FUNCTION IF EXISTS tps.srce_import(text, jsonb);
CREATE OR REPLACE FUNCTION tps.srce_import(_srce text, _recs jsonb) RETURNS jsonb

/*--------------------------------------------------------
0. test if source exists
1. create pending list
2. get unqiue pending keys
3. see which keys not already in tps.trans
4. insert pending records associated with keys that are not already in trans
5. insert summary to log table
*/---------------------------------------------------------

--to-do
--return infomation to a client via json or composite type


AS $f$
DECLARE
    _t text;
    _c text;
    _log_info jsonb;
    _log_id text;
    _cnt numeric;
    _message jsonb;
    --_recs jsonb;
    --_srce text;
    _defn jsonb;
    _MESSAGE_TEXT text;
    _PG_EXCEPTION_DETAIL text;
    _PG_EXCEPTION_HINT text;

BEGIN

    --_path := 'C:\users\fleet\downloads\discover-recentactivity-20171031.csv';
    --_srce := 'dcard';
    --_recs:= $$[{"Trans. Date":"1/2/2018","Post Date":"1/2/2018","Description":"GOOGLE *YOUTUBE VIDEOS G.CO/HELPPAY#CAP0H07TXV","Amount":4.26,"Category":"Services"},{"Trans. Date":"1/2/2018","Post Date":"1/2/2018","Description":"MICROSOFT *ONEDRIVE 800-642-7676 WA","Amount":4.26,"Category":"Services"},{"Trans. Date":"1/3/2018","Post Date":"1/3/2018","Description":"CLE CLINIC PT PMTS 216-445-6249 OHAK2C57F2F0B3","Amount":200,"Category":"Medical Services"},{"Trans. Date":"1/4/2018","Post Date":"1/4/2018","Description":"AT&T *PAYMENT 800-288-2020 TX","Amount":57.14,"Category":"Services"},{"Trans. Date":"1/4/2018","Post Date":"1/7/2018","Description":"WWW.KOHLS.COM #0873 MIDDLETOWN OH","Amount":-7.9,"Category":"Payments and Credits"},{"Trans. Date":"1/5/2018","Post Date":"1/7/2018","Description":"PIZZA HUT 007946 STOW OH","Amount":9.24,"Category":"Restaurants"},{"Trans. Date":"1/5/2018","Post Date":"1/7/2018","Description":"SUBWAY 00044289255 STOW OH","Amount":10.25,"Category":"Restaurants"},{"Trans. Date":"1/6/2018","Post Date":"1/7/2018","Description":"ACME NO. 17 STOW OH","Amount":103.98,"Category":"Supermarkets"},{"Trans. Date":"1/6/2018","Post Date":"1/7/2018","Description":"DISCOUNT DRUG MART 32 STOW OH","Amount":1.69,"Category":"Merchandise"},{"Trans. Date":"1/6/2018","Post Date":"1/7/2018","Description":"DISCOUNT DRUG MART 32 STOW OH","Amount":2.19,"Category":"Merchandise"},{"Trans. Date":"1/9/2018","Post Date":"1/9/2018","Description":"CIRCLE K 05416 STOW OH00947R","Amount":3.94,"Category":"Gasoline"},{"Trans. Date":"1/9/2018","Post Date":"1/9/2018","Description":"CIRCLE K 05416 STOW OH00915R","Amount":52.99,"Category":"Gasoline"},{"Trans. Date":"1/13/2018","Post Date":"1/13/2018","Description":"AUTOZONE #0722 STOW OH","Amount":85.36,"Category":"Automotive"},{"Trans. Date":"1/13/2018","Post Date":"1/13/2018","Description":"DISCOUNT DRUG MART 32 STOW OH","Amount":26.68,"Category":"Merchandise"},{"Trans. Date":"1/13/2018","Post Date":"1/13/2018","Description":"EL CAMPESINO STOW OH","Amount":6.5,"Category":"Restaurants"},{"Trans. Date":"1/13/2018","Post Date":"1/13/2018","Description":"TARGET STOW OH","Amount":197.9,"Category":"Merchandise"},{"Trans. Date":"1/14/2018","Post Date":"1/14/2018","Description":"DISCOUNT DRUG MART 32 STOW OH","Amount":13.48,"Category":"Merchandise"},{"Trans. Date":"1/15/2018","Post Date":"1/15/2018","Description":"TARGET.COM * 800-591-3869 MN","Amount":22.41,"Category":"Merchandise"},{"Trans. Date":"1/16/2018","Post Date":"1/16/2018","Description":"BUFFALO WILD WINGS KENT KENT OH","Amount":63.22,"Category":"Restaurants"},{"Trans. Date":"1/16/2018","Post Date":"1/16/2018","Description":"PARTA - KCG KENT OH","Amount":4,"Category":"Government Services"},{"Trans. Date":"1/16/2018","Post Date":"1/16/2018","Description":"REMEMBERNHU 402-935-7733 IA","Amount":60,"Category":"Services"},{"Trans. Date":"1/16/2018","Post Date":"1/16/2018","Description":"TARGET.COM * 800-591-3869 MN","Amount":44.81,"Category":"Merchandise"},{"Trans. Date":"1/16/2018","Post Date":"1/16/2018","Description":"TREE CITY COFFEE & PASTR KENT OH","Amount":17.75,"Category":"Restaurants"},{"Trans. Date":"1/17/2018","Post Date":"1/17/2018","Description":"BESTBUYCOM805526794885 888-BESTBUY MN","Amount":343.72,"Category":"Merchandise"},{"Trans. Date":"1/19/2018","Post Date":"1/19/2018","Description":"DISCOUNT DRUG MART 32 STOW OH","Amount":5.98,"Category":"Merchandise"},{"Trans. Date":"1/19/2018","Post Date":"1/19/2018","Description":"U-HAUL OF KENT-STOW KENT OH","Amount":15.88,"Category":"Travel/ Entertainment"},{"Trans. Date":"1/19/2018","Post Date":"1/19/2018","Description":"WALMART GROCERY 800-966-6546 AR","Amount":5.99,"Category":"Supermarkets"},{"Trans. Date":"1/19/2018","Post Date":"1/19/2018","Description":"WALMART GROCERY 800-966-6546 AR","Amount":17.16,"Category":"Supermarkets"},{"Trans. Date":"1/19/2018","Post Date":"1/19/2018","Description":"WALMART GROCERY 800-966-6546 AR","Amount":500.97,"Category":"Supermarkets"},{"Trans. Date":"1/20/2018","Post Date":"1/20/2018","Description":"GOOGLE *GOOGLE PLAY G.CO/HELPPAY#CAP0HFFS7W","Amount":2.12,"Category":"Services"},{"Trans. Date":"1/20/2018","Post Date":"1/20/2018","Description":"LOWE'S OF STOW, OH. STOW OH","Amount":256.48,"Category":"Home Improvement"},{"Trans. Date":"1/23/2018","Post Date":"1/23/2018","Description":"CASHBACK BONUS REDEMPTION PYMT/STMT CRDT","Amount":-32.2,"Category":"Awards and Rebate Credits"},{"Trans. Date":"1/23/2018","Post Date":"1/23/2018","Description":"INTERNET PAYMENT - THANK YOU","Amount":-2394.51,"Category":"Payments and Credits"},{"Trans. Date":"1/27/2018","Post Date":"1/27/2018","Description":"GIANT-EAGLE #4096 STOW OH","Amount":67.81,"Category":"Supermarkets"},{"Trans. Date":"1/27/2018","Post Date":"1/27/2018","Description":"OFFICEMAX/OFFICE DEPOT63 STOW OH","Amount":21.06,"Category":"Merchandise"},{"Trans. Date":"1/27/2018","Post Date":"1/27/2018","Description":"TARGET STOW OH","Amount":71,"Category":"Merchandise"},{"Trans. Date":"1/29/2018","Post Date":"1/29/2018","Description":"NETFLIX.COM NETFLIX.COM CA19899514437","Amount":14.93,"Category":"Services"},{"Trans. Date":"1/30/2018","Post Date":"1/30/2018","Description":"SQ *TWISTED MELTZ KENT OH0002305843011416898511","Amount":16.87,"Category":"Restaurants"},{"Trans. Date":"1/30/2018","Post Date":"1/30/2018","Description":"TARGET STOW OH","Amount":49.37,"Category":"Merchandise"}]$$::jsonb;

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
        RETURN _message;
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

    -----------insert pending rows that have key with no trans match-----------------------------------------------------------------------------------
    --need to look into mapping the transactions prior to loading

    , inserted AS (
        INSERT INTO
            tps.trans (srce, rec, ic)
        SELECT
            pl.srce
            ,pl.rec
            ,pl.json_key
        FROM 
            pending_list pl
            INNER JOIN unmatched_keys u ON
                u.json_key = pl.json_key
        ORDER BY
            pl.id ASC
        ----this conflict is only if an exact duplicate rec json happens, which will be rejected
        ----therefore, records may not be inserted due to ay matches with certain json fields, or if the entire json is a duplicate, reason is not specified
        RETURNING *
    )

    --------summarize records not inserted-------------------+------------------------------------------------------------------------------------------------

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
            "message":"error importing data"
        }
    $$::jsonb)
    ||jsonb_build_object('message_text',_MESSAGE_TEXT)
    ||jsonb_build_object('pg_exception_detail',_PG_EXCEPTION_DETAIL);
    return _message;
END;
$f$
LANGUAGE plpgsql

