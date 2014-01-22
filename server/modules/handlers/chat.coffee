{Controller} = require '../zmqcontroller'
{Message} = require '../message'

class ChatChannel
  constructor: ({@id, @name, @controller}) ->
    @users = []

  send: (msg) ->
    for user in @users
      console.log "Fan out #{msg} to #{user}"
      @controller.send {command: 'message', id:undefined, connectionid:user, data:{message:msg, channel:@id}}
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
      @channels[message.data.channel]?.send message.data.text

  init: ->
    @channels = {}

x = new ChatHandler

exports.ChatHandler = ChatHandler