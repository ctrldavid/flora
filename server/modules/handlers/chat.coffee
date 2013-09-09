{Message} = require '../message'

class ChatChannel
  constructor: ({@id, @name}) ->
    @users = []

  send: (msg) ->
    for user in @users
      user.send new Message 'chat', {channel: @id, @name, text:msg}

# Chat module
class ChatHandler
  constructor: ->
    @channels = {}
  commands:
    'subscribe': (data, sender) ->
      sender.send new Message 'echo', {data: data.data}

  message: (msg, sender) ->
    sender.send new Message 'echo', msg.data

exports.ChatHandler = ChatHandler
