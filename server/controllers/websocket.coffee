{Controller} = require '../zmqcontroller'
{Message} = require '../message'
{Reply} = require '../middleware/reply'
{Auth} = require '../middleware/auth'
uuid = require 'node-uuid'

ws = require 'ws'

class Client
  constructor: (@socket, @controller) ->
    @ip = @socket._socket.remoteAddress
    @session = {id:uuid.v4()}
    
    #console.log "#{ts()} New connection with IP #{@ip} and session #{@colour @session.id}"

    @socket.on 'message', (msg) =>
      message = JSON.parse msg
      #console.log "#{ts()} #{@pretty()} on [#{message.channel}] with id [#{message.id}]: [#{message.command}]. data:#{JSON.stringify(message.data)}"
      # pub.send ["#{message.channel}", "#{message.command}", "#{message.id}", "#{@session.id}", "#{JSON.stringify(message.data)}"]
      message.connectionid = @session.id
      @controller.xsend "ws/#{message.channel}/#{message.command}", message

    @socket.on 'close', () =>
      #console.log "#{ts()} Disconnect from #{@pretty()}.",arguments

  send: (msg) ->
    #console.log "Trying to send", msg
    try 
      @socket.send JSON.stringify msg
    catch error
      console.log 'shit son it is closed'

# Websocket module
class WebsocketController extends Controller
  # middleware: [Reply, Auth]
  events: 
    'ws/send': (message) ->
      connectionid = message.connectionid
      channel = message.channel
      command = message.command
      id = message.id
      data = JSON.stringify message.data
      @log "In theory sending message to #{message.connectionid} on channel #{message.channel}. Command: #{message.command}"
      #console.log "ZMQ: #{channel}:#{command} -> #{connectionid}"
      @clients[connectionid]?.send {channel, command, id, data}

      
  init: ->
    @clients = {}
    @server = new ws.Server port: 5000
    @server.on 'connection', (socket) =>
      c = new Client socket, this
      @log "new ws connection. giving id #{@c c.session.id}."
      @clients[c.session.id] = c


    # sub = zmq.socket 'sub'
    # sub.connect 'tcp://127.0.0.1:7000'
    # sub.subscribe ''
    # sub.on 'message', (channel, command, id, connectionid, data) ->
    #   console.log "ZMQ: #{channel}:#{command} -> #{connectionid}"
    #   clients[connectionid.toString()]?.send {channel:channel.toString(), command:command.toString(), id:id.toString(), data:data.toString()}

    @log 'Server started.'



exports.WebsocketController = WebsocketController

