path = require 'path'
fs   = require 'fs-extra'

globalConfig = undefined

exports.configDir =
  path.join process.env.HOME, '.heroku-publisher'

exports.configFile =
  path.join exports.configDir, 'config'

exports.initialize = ->
  unless fs.existsSync exports.configFile
    config = heroku: { apiKey: null }
    exports.save config

exports.getGlobal = ->
  globalConfig ?= fs.readJSONSync exports.configFile

exports.save = (config) ->
 fs.outputJSONSync exports.configFile, config
