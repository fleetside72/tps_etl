#!/usr/bin/env node

require('dotenv').config();
const express = require('express');
var https = require('https');
var bodyParser = require('body-parser');
const server = express();
const pg = require('pg');
var mult = require('multer');
var upload = mult({ encoding: "utf8" });
var csvtojson = require('csvtojson');

//---------read sql files into variables----------------
var fs = require('fs');
var readline = require('readline');


//---------------setup TLS------------------------------------
var options = {
    key: fs.readFileSync(process.env.wd + 'key.pem'),
    cert: fs.readFileSync(process.env.wd + 'cert.pem'),
    passprase: []
};

https.createServer(options,server).listen(process.env.nodeport, () => {
    console.log('started on '+ process.env.nodeport)
});


//---------------database connection-----------------------
var Postgres = new pg.Client({
    user: process.env.user,
    password: process.env.password,
    host: process.env.host,
    port: process.env.port,
    database: process.env.database,
    ssl: false,
    application_name: "tps_etl_api"
});
Postgres.FirstRow = function(inSQL,args, inResponse)
{
    Postgres.query(inSQL,args, (err, res) => {
        if (err === null)
        {
            inResponse.json(res.rows[0]);
            return;
        }
        inResponse.json(err.stack);
    });
};
Postgres.connect();


//----------------------------------------------------------source definitions-------------------------------------------------------------------------------------------------------------------------

//----------returns array of all sources--------------------------
server.get("/source", function (inReq, inRes)
{
    var sql = "SELECT jsonb_agg(defn) source_list FROM tps.srce";
    Postgres.FirstRow(sql,[], inRes);
});
//----------returns message about status and error description--
server.post("/source_single", bodyParser.json(), function (inReq, inRes)// remove body parsing, just pass post body to the sql string build
{
    var sql = "SELECT x.message FROM tps.srce_set($1::jsonb) as x(message)";
    Postgres.FirstRow(sql,[JSON.stringify(inReq.body)], inRes);
});
//------assume inboud info is json array of definitions to set--
server.post("/source", bodyParser.json(), function (inReq, inRes)// remove body parsing, just pass post body to the sql string build
{
    x = inReq.body;
    var sql =   "SELECT x.message FROM tps.srce_overwrite_all($1::jsonb) x(message)";
    console.log(JSON.stringify(inReq.body));
    Postgres.FirstRow(sql,[JSON.stringify(inReq.body)], inRes);
});

//----------------------------------------------------------regex instrUctions-------------------------------------------------------------------------------------------------------------------------
//list all regex operations
server.get("/regex", function (inReq, inRes)
{
    var sql = "SELECT jsonb_agg(regex) regex FROM tps.map_rm WHERE srce = $1::text";
    Postgres.FirstRow(sql, [inReq.query.srce], inRes);
});

//set one or more map definitions
server.post("/regex", bodyParser.json(), function (inReq, inRes)
{
    var sql = "SELECT x.message FROM tps.srce_map_def_set($1::jsonb) as x(message)";
    Postgres.FirstRow(sql, [JSON.stringify(inReq.body)], inRes);
});

//------------------------------------------------------------mappings---------------------------------------------------------------------------------------------------------------------------------

//list unmapped items flagged to be mapped   ?srce=
server.get("/unmapped_all", function (inReq, inRes)
{
    var sql = "SELECT jsonb_agg(row_to_json(x)::jsonb) regex FROM tps.report_unmapped_recs($1::text) x";
    Postgres.FirstRow(sql,[inReq.query.srce], inRes);
});

//list unmapped items flagged to be mapped   ?srce=
server.get("/unmapped", function (inReq, inRes)
{
    var sql = "SELECT jsonb_agg(row_to_json(x)::jsonb) regex FROM tps.report_unmapped($1::text) x";
    Postgres.FirstRow(sql,[inReq.query.srce], inRes);
});

server.get("/mapping", function (inReq, inRes)
{
    var sql = "SELECT jsonb_agg(row_to_json(x)::jsonb) regex FROM tps.map_rv x WHERE srce = $1::text";

    Postgres.FirstRow(sql,[inReq.query.srce], inRes);
});

//add entries to lookup table
server.post("/mapping", bodyParser.json(), function (inReq, inRes)
{
    var sql = "SELECT x.message FROM tps.map_rv_set($1::jsonb) as x(message)";
    Postgres.FirstRow(sql,[JSON.stringify( inReq.body)], inRes);
});

//---------------------------------------------------------list imports--------------------------------------------------------------------------------------------------------------------------------

server.get("/import_log", function (inReq, inRes)
{
    var sql = "SELECT jsonb_agg(row_to_json(l)::jsonb) regex FROM tps.trans_log l";
    Postgres.FirstRow(sql,[], inRes);
});


//-------------------------------------------------------------import data-----------------------------------------------------------------------------------------------------------------------------

server.use("/import", upload.single('upload'), function (inReq, inRes) {

    console.log("should have gotten file as post body here");
    var csv = inReq.file.buffer.toString('utf8')
    //{headers: "true", delimiter: ",", output: "jsonObj", flatKeys: "true"}
    csvtojson({ flatKeys: "true" }).fromString(csv).then(
        (x) => {
            var sql = "SELECT x.message FROM tps.srce_import($1, $2::jsonb) as x(message)"
            console.log(sql);
            Postgres.FirstRow(sql, [inReq.query.srce, JSON.stringify(x)], inRes);
        }
    );
    }
);

//----------------------------------------------------------list import logs---------------------------------------------------------------------------------------------------------------------------

server.get("/import_log", function (inReq, inRes)
{
    var sql = "SELECT jsonb_agg(info) info FROM tps.trans_log WHERE info @> $1::jsonb";
    Postgres.FirstRow(sql, [inReq.query], inRes);
});

//-------------------------------------------------------------suggest source def----------------------------------------------------------------------------------------------------------------------

server.use("/csv_suggest", upload.single('upload'), function (inReq, inRes) {

    console.log("should have gotten file as post body here");
    var csv = inReq.file.buffer.toString('utf8')
    //{headers: "true", delimiter: ",", output: "jsonObj", flatKeys: "true"}
    csvtojson({ flatKeys: "true" }).fromString(csv).then(
        (x) => {
            var sug = {
                schemas: {
                    default: []
                },
                loading_function: "csv",
                source:"client_file",
                name: "",
                constraint: []
            };
            for (var key in x[0]) {
                var col = {};
                //test if number
                if (!isNaN(parseFloat(x[0][key])) && isFinite(x[0][key])) {
                    //if is a number but leading character is -0- then it's text
                    if (x[0][key].charAt(0) == "0"){
                        col["type"] = "text";
                    }
                    //if number and leadign character is not 0 then numeric
                    else {
                        col["type"] = "numeric";
                    }
                } 
                //if can cast to a date within a hundred years its probably a date
                else if (Date.parse(x[0][key]) > Date.parse('1950-01-01') && Date.parse(x[0][key]) < Date.parse('2050-01-01')) {
                    col["type"] = "date";
                }
                //otherwise its text
                else {
                    col["type"] = "text";
                }
                col["path"] = "{" + key + "}";
                col["column_name"] = key;
                sug.schemas.default.push(col);
            }
            console.log(sug);
            inRes.json(sug);
        }
    );
    }
);