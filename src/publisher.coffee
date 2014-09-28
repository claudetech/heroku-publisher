fs         = require 'fs-extra'
path       = require 'path'
Repository = require('git-cli').Repository
_          = require 'lodash'
exec       = require('child_process').exec

config     = require './config'
herokuGit  = require './heroku-git'
appManager = require './app-manager'

templatesDir = path.join path.dirname(__dirname), 'templates'

NODE_STATIC_VERSION = '^0.7.4'

copyFiles = (conf, appName) ->
  fs.copySync path.join(templatesDir, 'Procfile'), 'Procfile'
  serverRawContent = fs.readFileSync path.join(templatesDir, 'server.js'), 'utf8'
  serverContent = _.template(serverRawContent)(conf)
  fs.writeFileSync 'server.js', serverContent
  conf = if fs.existsSync('package.json') then fs.readJSONSync('package.json') else { name: appName }
  conf.dependencies ?= {}
  unless _.find(conf.dependencies, (ver, dep) -> dep == 'node-static')
    conf.dependencies['node-static'] = NODE_STATIC_VERSION
  fs.writeJSONSync 'package.json', conf

exports.addNodeServer = (directory, options, appName, callback) ->
  cwd = process.cwd()
  process.chdir directory
  projectConfig = config.getProjectConfig(directory)
  conf = _.extend {}, projectConfig, options
  copyFiles conf, appName
  callback conf

prepare = (directory, options, callback) ->
  herokuGit.setupDirectory directory, (err, repo, branch) ->
    appManager.initializeApp repo, options, (err, app) ->
      exports.addNodeServer directory, options, app.name, (conf) ->
        callback repo, app, branch, conf

upload = (repo, app, branch, conf, callback) ->
  herokuGit.addCommit repo, '.', {}, ->
    herokuGit.addCommit repo, conf.publicDir, { force: true }, ->
      repo.push ['heroku', 'heroku:master'], ->
        repo.checkout branch, ->
          callback null, app

build = (command, callback, baseCallback) ->
  exec command, (error, stdout, stderr) ->
    return baseCallback(error) unless error is null
    callback()

exports.publish = (options, callback) ->
  directory = options.directory ? process.cwd()
  prepare directory, options, (repo, app, branch, conf) ->
    cb = -> upload repo, app, branch, conf, callback
    if options.build?
      build(options.build, cb, callback)
    else
      cb()
