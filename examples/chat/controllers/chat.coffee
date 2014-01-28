define [
  'controller'
], (Controller) ->

  class ChatController extends Controller
    channels: 
      chat:
        message: (data) ->
          console.log "Chat controller got message", data
          @trigger 'message', {text: data.message, sender: data.sender}

    init: ->
      @history = []
      @idctr = 0

    sendMessage: (text) ->
      @send 'chat', 'message', {text, channel:'global'}, @idctr++
      # @trigger 'message', {text, channel: 'global'}

    subscribe: (channel) ->
      @send 'chat', 'subscribe', {channel}, @idctr++

      

  return {ChatController}
