define [
  'backbone'
  'events'
], (Backbone, Events) ->
  _initialised = false
  class Stem extends Events
    initialise: (url, port) ->
      return if _initialised
      @ws = new window.WebSocket "ws://#{url}:#{port}/"
      @ws.onmessage = @receive
      _initialised = true

    receive: (message) =>
      data = message.data
      console.log data
      @trigger 'receive', data
    send: (message) ->
      console.log message
      @ws.send message
      @trigger 'send', message

  # Oh shit son singleton y'all gonna get wrecked
  return new Stem