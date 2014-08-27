publisher = require '../publisher'

exports.run = (options) ->
  options.retry ?= true
  console.log "Publishing your application to Heroku."
  publisher.publish options, (err, app) ->
    return console.warn(err) unless err is null
    console.log "Your app has been published at #{app.web_url}"
