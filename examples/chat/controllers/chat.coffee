define [
  'controller'
], (Controller) ->

  class ChatEntry

  class ChatMessage extends ChatEntry
    type: 'message'

  class ChatInfo extends ChatEntry
    type: 'info'
    constructor: (@text) ->

  class ChatError extends ChatEntry
    type: 'error'

  class ChatController extends Controller
    commands:
      'chat message': 'incomingMessage'
      'chat throttle': 'setThrottle'

    init: ->
      @history = []
      @throttle = 0

    sendMessage: (text) ->
      if @throttle > 0
        @add new ChatInfo "Please wait #{@throttle} seconds."
        return

      @command 'chat message', {text}

    incomingMessage: (cmd) ->
      @add new ChatMessage cmd.sender, cmd.text

    setThrottle: (cmd) ->
      @throttle = cmd.throttle

    add: (entry) ->
      @history.push entry
      @trigger 'new', entry

  return {ChatController}
