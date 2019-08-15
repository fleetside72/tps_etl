#!/usr/bin/env node

require('dotenv').config();
const express = require('express');
var https = require('https');
var bodyParser = require('body-parser');
const server = express();
const pg = require('pg');

//---------read sql files into variables----------------
var fs = require('fs');
var readline = require('readline');
//-------------------------------------------------------

var options = {
    key: fs.readFileSync(process.env.wd + 'key.pem'),
    cert: fs.readFileSync(process.env.wd + 'cert.pem'),
    passprase: []
};

https.createServer(options,server).listen(process.env.nodeport, () => {
    console.log('started on '+ process.env.nodeport)
});