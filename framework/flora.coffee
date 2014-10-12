require.config
  waitSeconds: 0
  shim:
    # backbone:
    #   deps: ['underscore', '$']
    #   exports: 'Backbone'
    #   init: () -> 
    #     console.log window.Backbone
    #     ret = Backbone.noConflict()
    #     delete window.Backbone
    #     console.log window.Backbone
    #     return ret
    underscore:
      exports: '_'
      init: () -> 
        ret = _.noConflict()
        delete window._
        return ret
    $:
      exports: '$'
      init: () -> 
        ret = $.noConflict()
        delete window.$
        # delete window.jQuery  # Bootstrap still checks for a global.
        return ret

    'jade.runtime':
      exports: 'jade'
      init: () ->
        ret = jade
        delete window.jade
        return ret
     
  map:
    'backbone':
      jquery: '$'   # Backbone requests 'jquery'. need to give it $ instead.

  paths:
    underscore: 'vendor/underscore'
    backbone: 'vendor/backbone-min'
    $: 'vendor/jquery-2.1.0.min'
    moment: 'vendor/moment'
    'jade.runtime': 'vendor/jade.runtime'
    
    promise: 'vendor/promise-0.1.1.min'

    view: 'base/view'
    application: 'base/application'
    events: 'base/events'
    controller: 'base/controller'
    pagesystem: 'base/pagesystem'


require [
  'main'
  'promise' # Shim for ES6 promises.
], (Main) ->
  #document.getElementById('loader').style.display = 'none'
  loader = document.getElementById 'loader'
  loader.parentElement.removeChild loader

