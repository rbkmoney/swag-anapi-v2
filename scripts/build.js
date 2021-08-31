#!/usr/bin/env node
'use strict';
const Path = require('path');

let TARGET_DIR = 'web_deploy';
if (process.argv[2]) {
    TARGET_DIR = process.argv[2]
}

require('shelljs/global');
set('-e');

mkdir('-p', TARGET_DIR);

cp('-R', 'web/*', TARGET_DIR + '/');

exec('npm run swagger bundle --        -o ' + TARGET_DIR + '/swagger.json');
exec('npm run swagger bundle -- --yaml -o ' + TARGET_DIR + '/swagger.yaml');
