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
      data = JSON.parse message.data
      console.log data
      @trigger 'receive', data
      if data.channel?
        @trigger "receive-#{data.channel}", data
    send: (channel, message) ->
      @ws.send {channel, data:message}
      @trigger 'send', {channel, data:message}



  # Oh shit son singleton y'all gonna get wrecked
  return new Stem