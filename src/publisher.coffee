fs         = require 'fs-extra'
path       = require 'path'
Repository = require('git-cli').Repository
npm        = require 'npm'
_          = require 'lodash'

config     = require './config'
herokuGit  = require './heroku-git'
appManager = require './app-manager'

templatesDir = path.join path.dirname(__dirname), 'templates'

installNodeStatic = ->
  doSave = npm.config.get 'save'
  npm.config.set 'save', true
  npm.commands.install ['node-static']
  npm.config.set 'save', doSave

copyFiles = (config) ->
  fs.copySync path.join(templatesDir, 'Procfile'), 'Procfile'
  serverRawContent = fs.readFileSync path.join(templatesDir, 'server.js'), 'utf8'
  serverContent = _.template(serverRawContent)(config)
  fs.writeFileSync 'server.js', serverContent

exports.addNodeServer = (directory, callback) ->
  cwd = process.cwd()
  process.chdir directory

  projectConfig = config.getProjectConfig(directory)
  npm.load ->
    installNodeStatic()
    copyFiles projectConfig
    callback()

exports.publish = (options, callback) ->
  directory = options.directory ? process.cwd()
  herokuGit.setupDirectory directory, (err, repo) ->
    appManager.initializeApp repo, options, callback
