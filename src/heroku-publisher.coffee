fs         = require 'fs'
path       = require 'path'
Repository = require('git-cli').Repository

exports.publish = (options, callback) ->
  directory = options.directory ? process.cwd()
  setupDirectory directory
  callback()
