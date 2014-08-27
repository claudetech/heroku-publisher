fs         = require 'fs-extra'
path       = require 'path'
Repository = require('git-cli').Repository
_          = require 'lodash'

config     = require './config'
herokuGit  = require './heroku-git'
appManager = require './app-manager'

templatesDir = path.join path.dirname(__dirname), 'templates'

NODE_STATIC_VERSION = '^0.7.4'

copyFiles = (config, appName) ->
  fs.copySync path.join(templatesDir, 'Procfile'), 'Procfile'
  serverRawContent = fs.readFileSync path.join(templatesDir, 'server.js'), 'utf8'
  serverContent = _.template(serverRawContent)(config)
  fs.writeFileSync 'server.js', serverContent
  conf = if fs.existsSync('package.json') then fs.readJSONSync('package.json') else { name: appName }
  conf.dependencies ?= {}
  unless _.find(conf.dependencies, (ver, dep) -> dep == 'node-static')
    conf.dependencies['node-static'] = NODE_STATIC_VERSION
  fs.writeJSONSync 'package.json', conf

exports.addNodeServer = (directory, appName, callback) ->
  cwd = process.cwd()
  process.chdir directory
  projectConfig = config.getProjectConfig(directory)
  copyFiles projectConfig, appName
  callback projectConfig

prepare = (directory, options, callback) ->
  herokuGit.setupDirectory directory, (err, repo, branch) ->
    appManager.initializeApp repo, options, (err, app) ->
      exports.addNodeServer directory, app.name, (projectConfig) ->
        callback repo, app, branch, projectConfig

upload = (repo, app, branch, projectConfig, callback) ->
  herokuGit.addCommit repo, projectConfig.publicDir, ->
    repo.push ['heroku', 'heroku:master'], ->
      repo.checkout branch, ->
        callback null, app

exports.publish = (options, callback) ->
  directory = options.directory ? process.cwd()
  prepare directory, options, (repo, app, branch, projectConfig) ->
    upload repo, app, branch, projectConfig, callback
