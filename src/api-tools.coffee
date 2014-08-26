_         = require 'lodash'
readline  = require 'readline'
HerokuApi = require 'heroku-legacy'
prompt    = require 'prompt'

config    = require './config'
prompt.message = ''

exports.login = (options, callback) ->
  [options, callback] = [{}, options] if _.isFunction(options)
  properties = [
    { name: 'username', message: 'Email' }
    { name: 'password', hidden: true, message: 'Password' }
  ]
  prompt.start()

  unless options.silence
    console.log 'Please enter your Heroku credentials.'
    console.log 'They are used to get your API key and will NOT be saved.'

  prompt.get properties, (err, result) ->
    new HerokuApi result, (err, api) ->
      if err == null
        conf = config.getGlobal()
        conf.heroku.apiKey = api._apiKey
        config.save conf
        callback null, api
      else
        console.log 'Could not login. Please try again.'
        return callback?(err, null) unless options.retry
        cb = (err, api) ->
          return callback err, api if err == null
          exports.login { silence: true, retry: false }, cb
        cb err, null

exports.authenticate = (options, callback) ->
  [options, callback] = [{}, options] if _.isFunction(options)
  apiKey = config.getGlobal().heroku?.apiKey
  return exports.login(callback) unless apiKey?
  api = new HerokuApi apiKey: apiKey
  api.getUser (err, res) ->
    if err == null
      callback null, api
    else
      exports.login options, callback
