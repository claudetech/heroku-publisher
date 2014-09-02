_          = require 'lodash'
fs         = require 'fs'
path       = require 'path'
Repository = require('git-cli').Repository

prepareBranch = (repo, branch, callback) ->
  repo.checkout 'heroku', (err) ->
    repo.merge 'master', ->
      callback?(err, repo, branch)

checkBranch = (repo, callback) ->
  repo.currentBranch (err, branch) ->
    repo.branch (err, branches) ->
      cb = -> prepareBranch repo, branch, callback
      if 'heroku' in branches then cb() else repo.branch('heroku', cb)

ignoreNodeModules = (directory, callback) ->
  file = path.join directory, '.git', 'info', 'exclude'
  if fs.readFileSync(file, 'utf8').indexOf('/node_modules') == -1
    fs.appendFileSync file, '/node_modules'
  callback()

runSetup = (repo, callback) ->
  ignoreNodeModules repo.workingDir(), ->
    exports.addCommit repo, '.', {}, ->
      checkBranch repo, callback

exports.setupDirectory = (directory, callback) ->
  if fs.existsSync path.join(directory, '.git')
    runSetup new Repository(path.join(directory, '.git')), callback
  else
    Repository.init directory, (err, repo) ->
      runSetup repo, callback

exports.addCommit = (repo, dir, opts, callback) ->
  options = _.extend { all: true }, opts
  repo.add [dir], options, ->
    repo.commit 'Preparing to upload to Heroku.', ->
      callback()
