require.config
  waitSeconds: 0
  shim:
    'backbone':
      deps: ['underscore', '$']
      exports: 'Backbone'
      init: () -> Backbone.noConflict()
    underscore:
      exports: '_'
      init: () -> _.noConflict()
    $:
      exports: '$'
      init: () -> $.noConflict()

  paths:
    underscore: 'vendor/underscore'
    backbone: 'vendor/backbone'
    $: 'vendor/jquery-2.1.0.min'
    moment: 'vendor/moment'
    
    view: 'base/view'
    application: 'base/application'
    events: 'base/events'
    controller: 'base/controller'

require [
  'main'
], (Main) ->
  document.getElementById('loader').style.display = 'none'

