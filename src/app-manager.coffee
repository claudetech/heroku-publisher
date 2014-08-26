_        = require 'lodash'
apiTools = require './api-tools'

setRemote = (repo, app, options, callback) ->
  console.log app


getOptions = (repo, options={}, callback) ->
  [options, callback] = [{}, options] if _.isFunction(options)
  options.appName ?= repo.workingDir()
  [options, callback]

exports.createApp = (repo, options, callback) ->
  [options, callback] = getOptions repo, options, callback

exports.initializeApp = (repo, options, callback) ->
  [options, callback] = getOptions repo, options, callback
  apiTools.authenticate (err, api) ->
    api.getApps (err, apps) ->
      return callback?(err) unless err is null
      app = _.find apps, (app) -> app.name == options.appName
      cb = -> setRemote repo, app, options, callback
      if app? then cb() else exports.createApp repo, options, cb
