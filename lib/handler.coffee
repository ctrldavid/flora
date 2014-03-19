{Controller} = require './zmqcontroller'
log = require('./log').bind 'Handler', 20

module.exports.load = (path) ->
  log "Starting controller: #{path}"
  controller = require path
  injected = controller.load Controller
  new injected