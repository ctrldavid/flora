server = require './server'
{argv} = require 'optimist'
path = require 'path'
module.exports.run = ->
  if argv._.length == 2
    [command, applicationPath] = argv._
  else if argv._.length == 1 
    [applicationPath] = argv._
  else 
    applicationPath = ""

  applicationPath = path.join process.cwd(), applicationPath

  port = argv.port ? 3000
  server.serve applicationPath, port