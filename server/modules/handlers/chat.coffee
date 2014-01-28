{Controller} = require '../zmqcontroller'
{Message} = require '../message'

class ChatChannel
  constructor: ({@id, @name, @controller}) ->
    @users = []

  send: (message) ->
    for user in @users
      console.log "Fan out to #{user}"#, message
      @controller.send {command: 'message', id:undefined, connectionid:user, data:{message:message.data.text, channel:@id, sender:message.connectionid}}
      #controller.send new Message 'chat', {channel: @id, @name, text:msg}

  addUser: (id) ->
    @users.push id

# Chat module
class ChatHandler extends Controller
  channel: 'chat'
  commands:
    subscribe: (message) ->
      console.log "#{message.connectionid} subscribed to #{message.data.channel}"
      #sender.send new Message 'echo', {data: data.data}
      @channels[message.data.channel] ?= new ChatChannel {id:message.data.channel, name:message.data.channel, controller:this}
      @channels[message.data.channel].addUser message.connectionid
    message: (message) ->
      console.log "#{message.connectionid} sent a message to #{message.data.channel}"
      @channels[message.data.channel]?.send message

  init: ->
    @channels = {}

x = new ChatHandler

exports.ChatHandler = ChatHandler