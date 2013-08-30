ws = require 'ws'
server = new ws.Server port: 5000
{EchoHandler} = require './modules/handlers/echo'
{Message} = require './modules/message'

session = require './modules/simple_sessions/simple_sessions'



sessions = {}
handlers = {}

ANSI =
  black: '\x1B[31;0m'
  red:   '\x1B[31;1m'
  rgb: (r, g, b) -> "\x1B[38;5;#{16+r*36+g*6+b}m"
  reset: '\x1B[0m'
  colour: (r,g,b) -> (str) -> ANSI.rgb(r, g, b) + str + ANSI.reset
  randomColour: () -> ANSI.colour Math.random()*6|0, Math.random()*6|0, Math.random()*6|0

class RedisHandler
  constructor: () ->
    @paths = {}
  commands:
    'subscribe': (message, sender) ->
      @paths[message.id] ?= []
      @paths[message.id].push sender
      sender.send {channel: 'redis', command: 'info', reply: message.reply, message: "Successfully subscribed to redis object #{message.id}"}
    'set': (message, sender) ->
      for subscriber in @paths[message.id]
        subscriber.send {channel: 'redis', command: 'set', id: message.id, data:{key: message.data.key, value: message.data.value}}

handlers['echo'] = new EchoHandler
handlers['redis'] = new RedisHandler


class Client
  constructor: (@socket) ->
    @ip = @socket._socket.remoteAddress
    @session = new session.Session @ip
    @colour = ANSI.randomColour()
    console.log "New connection with IP #{@ip} and session #{@colour @session.id}"

    @send new Message 'auth', {id: @session.id}

    @socket.on 'message', (msg) =>
      message = JSON.parse msg
      console.log "#{@pretty()} on [#{message.channel}] with id [#{message.id}]: [#{message.command}]. data:#{JSON.stringify(message.data)}"
      handlers[message.channel]?.commands?[message.command]?.apply(handlers[message.channel], [message, this])

    @socket.on 'close', () =>
      console.log "Disconnect from #{@pretty()}.",arguments

  pretty: -> @colour @session.id.match(/^.{8}/)[0]

  send: (msg) ->
    @socket.send JSON.stringify msg


server.on 'connection', (socket) ->
  c = new Client socket

