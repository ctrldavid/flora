{Controller} = require './zmqcontroller'
log = require('./log').bind 'Handler', 20
fs = require 'fs'

{Reply} = require '../base/middleware/reply'
{Auth} = require '../base/middleware/auth'

Middleware = {
  Reply
  Auth
}

module.exports.load = (path) ->
  handler = null
  load = ->
    log "Starting controller: #{path}"
    controller = require path
    injected = controller.load Controller, Middleware
    handler = new injected

  kill = ->
    return unless handler?
    log "Killing controller: #{path}"
    handler.deconstruct()
    handler = null

  fs.watch path, (event, filename) ->
    log "Watcher: #{event} on #{filename}"
    if event == 'change'
      kill()
      load()

  load()