fs         = require 'fs'
path       = require 'path'
Repository = require('git-cli').Repository

prepareBranch = (repo, callback) ->
  repo.checkout 'heroku', (err) ->
    callback?(err, repo)

checkBranch = (repo, callback) ->
  repo.branch (err, branches) ->
    cb = -> prepareBranch repo, callback
    if 'heroku' in branches then cb() else repo.branch('heroku', cb)

runSetup = (repo, callback) ->
  exports.addCommit repo, ->
    checkBranch repo, callback

exports.setupDirectory = (directory, callback) ->
  if fs.existsSync path.join(directory, '.git')
    runSetup new Repository(path.join(directory, '.git')), callback
  else
    Repository.init directory, (err, repo) ->
      runSetup repo, callback

exports.addCommit = (repo, callback) ->
  repo.add all: true, ->
    repo.commit 'Preparing to upload to Heroku.', ->
      callback()
