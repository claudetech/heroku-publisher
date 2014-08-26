publisher = require '../publisher'

exports.run = (options) ->
  options.retry ?= true
  publisher.publish options, (err, app) ->
    console.log err
    console.log app
    console.log 'published'
