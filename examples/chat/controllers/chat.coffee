define [
  'controller'
], (Controller) ->

  class ChatController extends Controller
    channel: 'chat'
    commands:
      message: (cmd) ->
        console.log "Chat controller got message from #{cmd.sender}: #{cmd.text}"
        @emit 'message', {text: cmd.text}

    init: ->
      @history = []
      @idctr = 0

    sendMessage: (text) ->
      @send 'message', {text, from:'me', to:'you'}, @idctr++
      @trigger 'message', {text, from:'me', to:'you'}

      

  return {ChatController}
