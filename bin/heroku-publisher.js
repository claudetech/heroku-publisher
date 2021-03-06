#!/usr/bin/env node

var path = require('path');
require(path.join(path.dirname(__dirname), 'lib', 'config')).initialize();
var cliParser = require(path.join(path.dirname(__dirname), 'lib', 'cli-parser'));
var args = cliParser.parse();
var module = path.join(path.dirname(__dirname), 'lib', 'commands', args.action);
require(module).run(args);
