ws = require 'ws'
server = new ws.Server port: 5000

session = require './modules/simple_sessions/simple_sessions'

# Need a common signature for messages. Fairly simple wrapper
class Message
  constructor: (@channel, @data) ->

sessions = {}
handlers = {}

ANSI =
  black: '\x1B[31;0m' 
  red:   '\x1B[31;1m'
  rgb: (r, g, b) -> "\x1B[38;5;#{16+r*36+g*6+b}m"
  reset: '\x1B[0m'
  colour: (r,g,b) -> (str) -> ANSI.rgb(r, g, b) + str + ANSI.reset

# Echo module
class EchoHandler
  handlers:
    'echo': (data, sender) ->
        sender.send {channel: 'echo', data: data.data}

  message: (msg, sender) ->
    sender.send JSON.stringify new Message 'echo', msg.data

class RedisHandler
  constructor: () ->
    @paths = {}
  handlers:
    'subscribe': (message, sender) ->      
      @paths[message.id] ?= []
      @paths[message.id].push sender
      sender.send JSON.stringify {channel: 'redis', command: 'info', reply: message.reply, message: "Successfully subscribed to redis object #{message.id}"}
    'set': (message, sender) ->
      for subscriber in @paths[message.id]
        subscriber.send JSON.stringify {channel: 'redis', command: 'set', id: message.id, data:{key: message.data.key, value: message.data.value}}

handlers['echo'] = new EchoHandler
handlers['redis'] = new RedisHandler

server.on 'connection', (socket) ->
  # console.log socket._socket.address()
  # console.log socket._socket.remoteAddress
  # console.log socket._socket.remotePort

  s = new session.Session socket._socket.remoteAddress
  s.colour = ANSI.colour Math.random()*6|0, Math.random()*6|0, Math.random()*6|0
  s.pretty = s.colour s.id.match(/^.{8}/)[0]
  sessions[s.id] = socket
  console.log "New connection with IP #{s.ip} and session #{s.colour s.id}"
  socket.send JSON.stringify new Message 'auth', {id: s.id}

  socket.on 'message', (msg) ->
    message = JSON.parse msg
    console.log "#{s.pretty} on [#{message.channel}] with id [#{message.id}]: [#{message.command}]. data:#{JSON.stringify(message.data)}"
    handlers[message.channel]?.handlers?[message.command]?.apply(handlers[message.channel], [message, socket])
    #socket.send JSON.stringify new Message 'echo', msg
  
  socket.on 'close', () ->
    console.log "Disconnect from #{s.pretty}.",arguments
