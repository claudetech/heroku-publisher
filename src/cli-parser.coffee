path = require 'path'
ArgumentParser = require('argparse').ArgumentParser

moduleInfo = require path.join(path.dirname(__dirname), 'package.json')
prog = moduleInfo.name

defaultAction = 'publish'

parser = new ArgumentParser(
  prog: prog
  version: moduleInfo.version
  addHelp: true
  description: 'Tool to publish static websites to Heroku.'
)

actionSubparser = parser.addSubparsers(
  title: 'Subcommands'
  dest: 'action'
)

loginParser = actionSubparser.addParser 'login',
  addHelp: true
  description: 'Login to Heroku.'

loginParser.addArgument ['-R', '--no-retry'],
  action: 'storeFalse'
  dest: 'retry'
  help: 'Do not prompt login again on failure.'

publishParser = actionSubparser.addParser 'publish',
  addHelp: true
  description: 'Publish to Heroku'

publishParser.addArgument ['-n', '--name'],
  action: 'store'
  dest: 'appName'
  metavar: 'APP_NAME'
  help: 'Application name to be created'

publishParser.addArgument ['-R', '--no-retry'],
  action: 'storeFalse'
  dest: 'retry'
  help: 'Do not prompt app name on failure.'


addDefaultArg = (args) ->
  hasArg = false
  args.forEach (arg) ->
    unless arg == 'node' || path.basename(arg, '.js') == prog || arg[0] == '-'
      return hasArg = true
  args.push defaultAction unless hasArg

exports.parse = (args=process.argv.slice(2)) ->
  addDefaultArg args
  parser.parseArgs args
