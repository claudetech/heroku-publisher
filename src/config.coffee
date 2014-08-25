path = require 'path'
fs   = require 'fs-extra'

exports.configDir =
  path.join process.env.HOME, '.heroku-publisher'

exports.configFile =
  path.join exports.configDir, 'config'

exports.initializeConfig = ->
  unless fs.existsSync exports.configFile
    config = { heroku: { apiKey: null } }
    fs.outputJSONSync exports.configFile, config

exports.getGlobalConfig = ->
  fs.readJSONSync exports.configFile
