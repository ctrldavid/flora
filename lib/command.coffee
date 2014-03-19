frontend = require './frontend'
proxy = require './proxy'
handler = require './handler'
argv = require('minimist')(process.argv.slice(2))
path = require 'path'
log = require('./log').bind 'Binary', 20

module.exports.run = ->
  # Check if we need to start the frontend
  if argv.frontend? or argv.f?
    applicationPath = argv.frontend ? argv.f ? ""
    applicationPath = path.join process.cwd(), applicationPath
    port = argv.port ? 3000
    frontend.serve applicationPath, port

  # Check if we need to start the proxy
  if argv.proxy? or argv.p?
    proxy.link 'tcp://127.0.0.1:8000', 'tcp://127.0.0.1:8500'

  # Check if we need to start any controllers
  if argv.controller? or argv.c?
    # argv.controller or argv.c can be either a string or an array of strings.
    # Array.prototype.concat works with both, so we can cheat a little.
    controllers = []
    controllers = controllers.concat argv.c if argv.c?
    controllers = controllers.concat argv.controller if argv.controller?

    # Need to make the paths absolute
    controllers = controllers.map (controllerPath) ->
      path.join process.cwd(), controllerPath
      
    handler.load controller for controller in controllers