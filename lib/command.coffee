argv = require('minimist')(process.argv.slice(2))
path = require 'path'
log = require('./log').bind 'Binary', 20

module.exports.run = ->
  log 'Starting flora'
  # Check if we need to start the frontend
  if argv.frontend? or argv.f?
    log 'Frontend server'
    frontend = require './frontend'    
    
    applicationPath = argv.frontend ? argv.f ? ""
    applicationPath = path.join process.cwd(), applicationPath
    port = argv.port ? 3000
    frontend.serve applicationPath, port

  # Check if we need to start the proxy
  if argv.proxy? or argv.p?
    log 'Proxy server'
    proxy = require './proxy'
    
    proxy.link 'tcp://127.0.0.1:8000', 'tcp://127.0.0.1:8500'

  # Check if we need to start any controllers
  if argv.controller? or argv.c?
    log 'Controllers'
    handler = require './handler'

    # argv.controller or argv.c can be either a string or an array of strings.
    # Array.prototype.concat works with both, so we can cheat a little.
    controllers = []
    controllers = controllers.concat argv.c if argv.c?
    controllers = controllers.concat argv.controller if argv.controller?

    # Need to make the paths absolute
    controllers = controllers.map (controllerPath) ->
      path.join process.cwd(), controllerPath
      
    handler.load controller for controller in controllers


  # Maybe using a channel is better than a controller
  if argv.x? or argv.x?
    log 'Channel test'

    loader = require './channel'

    # or argv.x can be either a string or an array of strings.
    # Array.prototype.concat works with both, so we can cheat a little.
    channelHandlers = []
    channelHandlers = channelHandlers.concat argv.x if argv.x?

    # Need to make the paths absolute
    channelHandlers = channelHandlers.map (controllerPath) ->
      path.join process.cwd(), controllerPath
      
    loader.load channelHandler for channelHandler in channelHandlers  