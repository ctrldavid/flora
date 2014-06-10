define [
  'underscore'
  'backbone'
  '$'
], (_, Backbone, $) ->

  # Lifecycle goals:
  # init     : Set any fields that have their data already available
  # inited   :
  # load     : Fire off async requests for data (eg: fetching models)
  # loaded   : Data available, set @locals for template
  # render   : template rendered, start adding subviews
  # rendered : Entire view and subviews are rendered
  # appear   : View is about to be added to the document
  # appeared : View has just been added to the document

  ###
  
  On create:
  ----------

  init (fn)
  init... (evt)
  inited

  load (fn)
  load... (evt)
  loaded

  render (fn)
  render... (evt)
  rendered


  On attach:
  ----------

  appear (fn)
  appear... (evt)
  <- Wait till parent has appeared
  appeared


  On detach:
  ----------

  disappear (fn)
  disappear...
  <- wait till all children have disappeared
  disappeared


  ###

  promiseError = (error) ->
    console.error "Error in View", error

  viewMethods =
    lifecycle: (view, evt) ->
      new Promise (resolve, reject) ->
        view[evt]?()
        viewMethods.eventLoop(view, evt, resolve)

    init: (view) ->
      viewMethods.lifecycle(view, 'init').then ->
        view.inited?()
        view.trigger 'inited'
        viewMethods.load view
      .catch promiseError

    load: (view) ->
      viewMethods.lifecycle(view, 'load').then ->
        view.loaded?()
        view.trigger 'loaded'
        viewMethods.render view
      .catch promiseError

    render: (view) ->
      view.$el.append view.template view.locals
      viewMethods.lifecycle(view, 'render').then ->
        view.rendered?()
        view.trigger 'rendered'
        viewMethods.appear view
      .catch promiseError

    appear: (view) ->
      viewMethods.lifecycle(view, 'appear').then ->
        # If the view has a parent wait till it has appeared before triggering
        # for the current view. (If the view has no parent then
        # $.when(undefined) will resolve immediately)
        # or if the parent is already _live $.when(true) will also resolve immediately
        appear = ->
          # call view.attach() to get attachment logic.
          # view.parentElement.append view.el
          attachMethods.append view
          view._live = true
          view.appeared?()
          view.trigger 'appeared'
          
        if view.parent?
          view.parent.Promise('appeared').then(appear).catch promiseError
        else
          appear()
      .catch promiseError

    eventLoop: (view, evt, resolve) ->
      view.trigger evt
      Promise.all(view._waits).then ->
        if view._waits.length > 0
          view._waits = []
          viewMethods.eventLoop view, evt, resolve
        else
          resolve()
      .catch promiseError
      
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
      # this.on 'all', (evt) ->
      #  console.log 'EVT', this.constructor.name, evt
      super
      @_waits = []
      @_subviews = []
      @_live = false
      @locals = {}
      @_promises = {}
      for event in ['init', 'inited', 'load', 'loaded', 'render', 'rendered', 'appear', 'appeared']
        do (event) =>
          @_promises[event] = new Promise (resolve, reject) =>
            @once event, resolve

      # Start loading the page immediately
      viewMethods.init this

    Promise: (evt) -> return @_promises[evt]

    waitOn: (dfd) ->
      @_waits.push dfd

    appendTo: (targetElement) ->
      @parentElement = targetElement
      # viewMethods.appear this

    prepend: (target, view) ->
      console.error 'NYI'
      # view.attach = (methods) -> methods.prepend
      # @append target, view

    append: (target, view) ->
      if typeof target == "string"
        target = @$el.find target

      view.parent = this
      @_subviews.push view


      # Start the appearing process
      view.appendTo target

      # Return a promise that resolves when the view renders so the caller
      # can wait on it.
      view.Promise 'rendered'


    #attach: (methods) -> methods.append
    # attach: ->
    #   viewMethods.appear this

    detach: ->
      @$el.detach()
      @parent._subviews = @parent._subviews.filter (view) => view != this
      @parent = null
      @_live = false


    reRender: ->
      # Not sure how this should work, perhaps a full reset, or just start with
      # 'loaded' and continue from there?
      @$el.empty()
      viewMethods.render this


  return View
