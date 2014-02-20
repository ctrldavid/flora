define [
  'controller'
], (Controller) ->

  class AuthController extends Controller
    channels: 
      auth:
        confirm: (data) ->
          alert JSON.stringify data

    init: ->
      @idctr = 0

    go: ->
      @send 'auth', 'request', {}

    sendMessage: (text) ->
      @send 'chat', 'message', {text, channel:'global'}, @idctr++
      # @trigger 'message', {text, channel: 'global'}

    subscribe: (channel) ->
      @send 'chat', 'subscribe', {channel}, @idctr++

      

  return {AuthController}
