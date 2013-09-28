define [
  'underscore'
  'backbone'
  '$'
  'events'
], (_, Backbone, $, Events) ->

  class Channel extends Events
    constructor: (@name, @stem) ->
    
    send: (command, data) ->
      frame = {channel: @name, command, data}
      @stem.send frame


  # The bit that handles the websocket.  This is where i'll put the longpolling
  # fallback when I get around to it. 
  # Still not sure how to interface with this. Could make a new object for each channel and listen
  # to events on that object...
  class Stem extends Events
    constructor: () ->
      @listeners = {}

    initialise: (url = window.location.hostname, port = 5000) ->
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


  controllerMethods =
    lifecycle: (controller, evt) ->
      dfd = $.Deferred()
      controller[evt]?()
      controllerMethods.eventLoop(controller, evt).then ->
        dfd.resolve()
      dfd.promise()

    init: (controller) ->
      controllerMethods.lifecycle(controller, 'init').then ->
        controller.inited?()
        controller.trigger 'inited'
        controllerMethods.load controller

    load: (controller) ->
      controllerMethods.lifecycle(controller, 'load').then ->
        controller.loaded?()
        controller.trigger 'loaded'
        # controllerMethods.render controller

    eventLoop: (controller, evt, dfd) ->
      dfd ?= $.Deferred()
      controller.trigger evt
      $.when.apply($, controller._waits).then ->
        if controller._waits.length > 0
          controller._waits = []
          controllerMethods.eventLoop controller, evt, dfd
        else
          dfd.resolve()
      dfd.promise()

  class Controller extends Events
    constructor: ->
      super
      @_waits = []

    # Helper method for turning an event into a deferred that can be waited on.
    eventDeferred: (evt) ->
      dfd = $.Deferred()
      @once evt, dfd.resolve
      dfd.promise()

    waitOn: (dfd) ->
      @_waits.push dfd

    command: (str, obj) ->
      [channel, command] = str.split " "

  return Controller
