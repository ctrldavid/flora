define [
  'underscore'
  'backbone'
  '$'
  'events'
], (_, Backbone, $, Events) ->

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
    lifecycle: (view, evt) ->
      dfd = $.Deferred()
      view[evt]?()
      viewMethods.eventLoop(view, evt).then ->
        dfd.resolve()
      dfd.promise()

    init: (view) ->
      viewMethods.lifecycle(view, 'init').then ->
        view.inited?()
        view.trigger 'inited'
        viewMethods.load view

    load: (view) ->
      viewMethods.lifecycle(view, 'load').then ->
        view.loaded?()
        view.trigger 'loaded'
        viewMethods.render view

    render: (view) ->
      view.$el.append view.template view.locals
      viewMethods.lifecycle(view, 'render').then ->
        view.rendered?()
        view.trigger 'rendered'
        viewMethods.appear view

    appear: (view) ->
      viewMethods.lifecycle(view, 'appear').then ->
        # If the view has a parent wait till it has appeared before triggering
        # for the current view. (If the view has no parent then
        # $.when(undefined) will resolve immediately)
        # or if the parent is already _live $.when(true) will also resolve immediately
        $.when(view.parent?._live || view.parent?.eventDeferred 'appeared').then ->
          # call view.attach() to get attachment logic.
          # view.parentElement.append view.el
          view.attach(attachMethods) view
          view._live = true
          view.appeared?()
          view.trigger 'appeared'

    eventLoop: (view, evt, dfd) ->
      dfd ?= $.Deferred()
      view.trigger evt
      $.when.apply($, view._waits).then ->
        if view._waits.length > 0
          view._waits = []
          viewMethods.eventLoop view, evt, dfd
        else
          dfd.resolve()
      dfd.promise()

  attachMethods =
    append: (view) ->
      view.parentElement.append view.el
    prepend: (view) ->
      view.parentElement.prepend view.el

  class View extends Backbone.View
    # trigger: ->
    #   console.log 'T2: ', @cid, arguments
    #   super
    constructor: ->
      super
      @_waits = []
      @_subviews = []
      @_live = false
      @locals = {}

    # Helper method for turning an event into a deferred that can be waited on.
    eventDeferred: (evt) ->
      dfd = $.Deferred()
      @once evt, dfd.resolve
      dfd.promise()

    waitOn: (dfd) ->
      @_waits.push dfd

    appendTo: (targetElement) ->
      @parentElement = targetElement
      viewMethods.init this

    prepend: (target, view) ->
      view.attach = (methods) -> methods.prepend
      @append target, view

    append: (target, view) ->
      if typeof target == "string"
        target = @$el.find target

      view.parent = this
      @_subviews.push view

      # Return a deferred that resolves when the view renders so the caller
      # can wait on it.
      dfd = view.eventDeferred 'rendered'

      # Start the loading process
      view.appendTo target

      return dfd

    attach: (methods) -> methods.append

    unload: ->
      @el.remove()
      @_live = false

    reRender: ->
      # Not sure how this should work, perhaps a full reset, or just start with
      # 'loaded' and continue from there?


  return View
