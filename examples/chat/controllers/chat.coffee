define [
  'controller'
], (Controller) ->

  class ChatController extends Controller
    channel: 'chat'
    commands:
      message: (data) ->
        console.log "Chat controller got message", data
        @trigger 'message', {text: data.message, sender: data.sender}

    init: ->
      @history = []
      @idctr = 0

    sendMessage: (text) ->
      @send 'message', {text, channel:'global'}, @idctr++
      # @trigger 'message', {text, channel: 'global'}

    subscribe: (channel) ->
      @send 'subscribe', {channel}, @idctr++

      

  return {ChatController}
