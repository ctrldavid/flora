ws = require 'ws'
server = new ws.Server port: 5000

session = require './modules/simple_sessions/simple_sessions'

# Need a common signature for messages. Fairly simple wrapper
class Message
  constructor: (@channel, @data) ->

server.on 'connection', (socket) ->
  # console.log socket._socket.address()
  # console.log socket._socket.remoteAddress
  # console.log socket._socket.remotePort

  s = new session.Session socket._socket.remoteAddress
  console.log "New connection with IP #{s.ip} and session id #{s.id}"
  socket.send JSON.stringify new Message 'auth', {id: s.id}
  socket.on 'message', (msg) ->
    console.log 'msg'
    socket.send JSON.stringify new Message 'echo', msg
  socket.on 'close', () ->
    console.log "bye", arguments

