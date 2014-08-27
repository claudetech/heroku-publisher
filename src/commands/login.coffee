apiTools = require '../api-tools'

exports.run = (opts) ->
  apiTools.login opts, (err, api) ->
    if err == null
      console.log 'Your API key has been saved.'
    else
      console.log 'Could not login.'


