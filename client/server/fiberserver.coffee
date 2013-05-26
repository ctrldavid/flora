express = require 'express'
jade = require 'jade'
fs = require 'fs'
path = require 'path'
coffee = require 'coffee-script'
stylus = require 'stylus'
Future = require 'fibers/future'

listen = (applicationPath="/", port = 3000) ->
  app = express()
  
  # This points to the directory this file is in.
  frameworkPath = path.join __dirname, '../framework'

  console.log "Serving: ", frameworkPath, applicationPath

listen()