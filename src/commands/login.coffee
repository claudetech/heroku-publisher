auth = require '../auth'

exports.run = (opts) ->
  auth.login opts, (err, api) ->
    if err == null
      console.log 'Your API key has been saved.'
    else
      console.log 'Could not login.'


