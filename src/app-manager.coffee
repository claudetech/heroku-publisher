_        = require 'lodash'
apiTools = require './api-tools'
prompt   = require './prompt'

setRemote = (repo, app, options, callback) ->
  repo.listRemotes (err, remotes) ->
    cb = (er) -> callback er, app
    if 'heroku' in remotes
      repo.setRemoteUrl 'heroku', app.git_url, cb
    else
      repo.addRemote 'heroku', app.git_url, cb

getOptions = (repo, options={}, callback) ->
  [options, callback] = [{}, options] if _.isFunction(options)
  options.appName ?= repo.workingDir() unless options.allowEmpty
  [options, callback]

exports.promptAppName = (callback) ->
  prompt.start()
  prompt.get name: 'appName', message: 'Application name', callback

exports.createApp = (repo, api, options, callback) ->
  [options, callback] = getOptions repo, options, callback
  params = if options.appName then {name: options.appName} else {}
  api.postApp params, (err, app) ->
    return callback(err, app) if err == null
    if err.code == 422 && options.retry
      console.warn err.message
      exports.promptAppName (err, result) ->
        return callback err unless err is null
        options.appName = result.appName
        delete options.appName if _.isEmpty(result.appName)
        exports.createApp repo, api, _.extend(allowEmpty: true, options), callback
    else
      callback err

createAndSetRemote = (repo, api, options, callback) ->
  exports.createApp repo, api, options, (err, app) ->
    return callback(err) unless err is null
    setRemote repo, app, options, callback

exports.initializeApp = (repo, options, callback) ->
  [options, callback] = getOptions repo, options, callback
  apiTools.authenticate (err, api) ->
    api.getApps (err, apps) ->
      return callback?(err) unless err is null
      app = _.find apps, (app) -> app.name == options.appName
      if app?
        setRemote repo, app, options, callback
      else
        createAndSetRemote repo, api, options, callback
