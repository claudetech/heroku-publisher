path = require 'path'
fs   = require 'fs-extra'
_    = require 'lodash'

globalConfig = undefined

defaultConfig =
  publicDir: 'public'

exports.configDir =
  path.join process.env.HOME, '.heroku-publisher'

exports.configFile =
  path.join exports.configDir, 'config'

exports.initialize = ->
  unless fs.existsSync exports.configFile
    config = heroku: { apiKey: null }
    exports.save config

exports.getLocal = (directory) ->
  configFile = path.join directory, '.heroku-publisher'
  if fs.existsSync configFile then fs.readJSONSync configFile else {}

exports.getProjectConfig = (directory) ->
  _.extends {}, defaultConfig, exports.getLocal(directory), exports.getGlobal().project

exports.getGlobal = ->
  globalConfig ?= fs.readJSONSync exports.configFile

exports.save = (config) ->
  fs.outputJSONSync exports.configFile, config
