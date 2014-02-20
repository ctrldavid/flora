{Controller} = require '../zmqcontroller'
{Message} = require '../message'

class ChatChannel
  constructor: ({@id, @name, @controller}) ->
    @clients = []
    @history = []

  send: (message) ->
    @history.push {message:message.data.text, channel:@id, sender:message.connectionid}
    @history = @history.slice -100 # Only store the last x messages in history
    for client in @clients
      console.log "Fan out to #{client.id}"#, message
      client.send 'chat', {command: 'message', id:undefined, data:{message:message.data.text, channel:@id, sender:message.connectionid}}
      #@controller.send 'chat', {command: 'message', id:undefined, connectionid:user, data:{message:message.data.text, channel:@id, sender:message.connectionid}}
      #controller.send new Message 'chat', {channel: @id, @name, text:msg}

  sendHistory: (client) ->
    client.send 'chat', {command: 'history', id:undefined, data:{messages:@history}}

  addClient: (client) ->
    @clients.push client

# Chat module
class ChatHandler extends Controller
  constructor : ->
    super
    @on 'client', 'sharded', 'chat', 'subscribe', (client, message) ->
      console.log "#{message.connectionid} subscribed to #{message.data.channel}"
      console.log client
      #sender.send new Message 'echo', {data: data.data}
      @channels[message.data.channel] ?= new ChatChannel {id:message.data.channel, name:message.data.channel, controller:this}
      @channels[message.data.channel].addClient client
      @channels[message.data.channel].sendHistory client

    @on 'client', 'unsharded', 'chat', 'message', (client, message) ->
      console.log "#{message.connectionid} sent a message to #{message.data.channel}"
      @channels[message.data.channel]?.send message

  init: ->
    @channels = {}

x = new ChatHandler

exports.ChatHandler = ChatHandler
