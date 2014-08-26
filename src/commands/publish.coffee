publisher = require '../heroku-publisher'

exports.run = (options) ->
  publisher.publish options, ->
    console.log 'published'
