define [
  'backbone'
  'events'
], (Backbone, Events) ->
  _initialised = false
  class Stem extends Events
    constructor: () ->
      @listeners = {}

    initialise: (url, port) ->
      return if @_initialised
      @ws = new window.WebSocket "ws://#{url}:#{port}/"
      @ws.onmessage = @receive
      @_initialised = true
      

    receive: (message) =>
      data = JSON.parse message.data
      @trigger 'receive', data
      if data.channel?
        if data.command?
          for listener in @listeners[data.channel]
            listener.handlers[data.command]?.apply listener, [data.id, data.data]
        @trigger "receive-#{data.channel}", data
    send: (frame) ->
      @ws.send JSON.stringify frame
      @trigger 'send', frame

    registerChannel: (channel, listener) ->
      @listeners[channel] ?= []
      @listeners[channel].push listener
      console.log "Added listener to #{channel}", listener



  # Oh shit son singleton y'all gonna get wrecked
  return new Stem