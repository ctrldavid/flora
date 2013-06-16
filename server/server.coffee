ws = require 'ws'
server = new ws.Server port: 5000

server.on 'connection', (connection) ->
  console.log 'con'
  connection.send "connected"
  connection.on 'message', (msg) ->
    console.log 'msg'
    connection.send "echo [#{msg}]"
  connection.on 'close', () ->
    console.log "bye", arguments

