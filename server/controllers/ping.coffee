{Controller} = require '../zmqcontroller'
{Message} = require '../message'

{Reply} = require '../middleware/reply'

# Ping module
class PingController extends Controller
  events: 
    'ws/ping/ping': @middleware([Reply]) (message) ->
      message.reply.send 'ping', {command: 'pong', id:undefined, data:{ts: (new Date).toUTCString()}}

  init: ->


exports.PingController = PingController
