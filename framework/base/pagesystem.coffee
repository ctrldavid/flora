define [
  'underscore'
  'backbone'
  'view'
], (_, Backbone, View) ->

  class PageSystem extends View
    # Dat ghetto template
    template: -> '<div class=\'js-pages\'></div>'
    constructor: (pages) ->
      # Dunno if we will ever need multiple page systems and routers...
      @router = new Backbone.Router

      # Grossss, should probably build the hash and pass it to the constructor
      for route, page of pages
        @router.route route, null, @switch(page)

      # Thanks for asking
      super

      # We hijack the click events on anchor tags to check if we need to 
      # use .navigate to switch to the target instead of reloading the page.
      @delegateEvents {
        # I like having anchor tags for links. This will prevent them from
        # reloading the page and instead use the pushstate router shit.
        'click a': (e) ->
          # We only want to deal with regular link activations
          return if e.altKey || e.ctrlKey || e.metaKey || e.shiftKey
          # And none of this middle mouse intercepting bullshit
          # (seems that middle mouse doesn't actually trigger a click event at
          # least in chrome. Need to research)
          # e.which == 1
          
          fragment = Backbone.history.getFragment e.target.pathname

          for handler in Backbone.history.handlers
            if handler.route.test fragment
              e.preventDefault()
              Backbone.history.navigate fragment, true
      }     
    
    rendered: ->
      # We only want to start the routing once the page has somewhere to live.
      Backbone.history.start {pushState: true}

    switch: (page) ->
      return =>
        # This needs to be refactored a bit... should I cache pages?
        @_current?.detach()
        @_current = new page
        @append '.js-pages', @_current
      

  return PageSystem
