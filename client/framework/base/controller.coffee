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
      @_ready = false
      @ws.onopen = =>
        @_ready = true
        @trigger 'ready'


    receive: (message) =>
      console.log 'message', message
      data = JSON.parse message.data
      @trigger 'receive', data
      console.log @listeners
      if data.channel?
        if data.command?
          for listener in @listeners[data.channel][data.command]
            listener.channels[data.channel][data.command]?.apply listener, [JSON.parse(data.data)]
        @trigger "receive-#{data.channel}", data
    send: (frame) ->
      @ws.send JSON.stringify frame
      @trigger 'send', frame

    registerHandler: (channel, command, controller) ->
      console.log 'Registering handler', channel, command, controller
      @listeners[channel] ?= {}
      @listeners[channel][command] ?= []
      @listeners[channel][command].push controller


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


  StemSingleton = new Stem
  StemSingleton.initialise()

  class Controller extends Events
    constructor: ->
      super
      @_waits = []
      
      # Start when the websocket connection is ready
      ready = =>
        # Loop through the list of handlers on the controller and set them up to receive messages.
        StemSingleton.registerHandler channel, command, this for command of @channels[channel] for channel of @channels

        controllerMethods.init(this)

      if StemSingleton._ready
        setTimeout ready, 0
      else
        StemSingleton.on 'ready', ready

    # Helper method for turning an event into a deferred that can be waited on.
    eventDeferred: (evt) ->
      dfd = $.Deferred()
      @once evt, dfd.resolve
      dfd.promise()

    waitOn: (dfd) ->
      @_waits.push dfd

    command: (str, obj) ->
      [channel, command] = str.split " "

    send: (channel, command, data, id) ->
      StemSingleton.send {channel, command, id, data}
      console.log {channel, command, data}

  return Controller
