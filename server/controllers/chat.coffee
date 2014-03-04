{Controller} = require '../zmqcontroller'
{Message} = require '../message'
{Reply} = require '../middleware/reply'
{Auth} = require '../middleware/auth'


###
  It would be nice to have middleware layers that controllers can use.
  The chat controller would use the 'auth' middleware, which would attach
  user information to the requests before they get handled.

  How it gets that information is a little difficult right now, possibly just
  grab it from redis, otherwise I might need to consider changing the SS zmq
  socket type from pubsub to req/reply
###

class ChatChannel
  constructor: ({@id, @name, @controller}) ->
    @clients = []
    @history = []

  send: (message) ->
    @history.push {message:message.data.text, channel:@id, sender:message.Auth.name}
    @history = @history.slice -100 # Only store the last x messages in history
    for client in @clients
      client.send 'chat', {command: 'message', id:undefined, data:{message:message.data.text, channel:@id, sender:message.Auth.name}}

  sendHistory: (client) ->
    client.send 'chat', {command: 'history', id:undefined, data:{messages:@history}}

  addClient: (client) ->
    @clients.push client

# Chat module
class ChatController extends Controller
  events:
    'ws/chat/subscribe': @middleware([Reply]) (message) ->
      @log "#{@c message.connectionid} subscribed to #{@c message.data.channel}"
      @channels[message.data.channel] ?= new ChatChannel {id:message.data.channel, name:message.data.channel, controller:this}
      @channels[message.data.channel].addClient message.reply
      @channels[message.data.channel].sendHistory message.reply

    'ws/chat/message': @middleware([Auth]) (message) ->
      @log "#{@s message.connectionid} sent a message to #{@c message.data.channel}"
      @log "Auth: #{JSON.stringify message.Auth}"
      @channels[message.data.channel]?.send message


  init: ->
    @channels = {}

exports.ChatController = ChatController
