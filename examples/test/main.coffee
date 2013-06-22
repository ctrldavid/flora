define [
  '$'
  'view'
  'application'
  'controllers/stem'
  'views/wsconsole'
  'views/wsdebug'
  'templates/layout'
], ($, View, Application, Stem, {ConsoleView}, {DebugView}, layoutT) ->

  class ExampleApp extends Application
    title: "Test page"
    template: layoutT
    load: ->
      Stem.initialise window.location.hostname, 5000
      Stem.on 'all', -> console.log "STEM", arguments
    render: ->
      @console = new ConsoleView
      @waitOn @append '.js-console', @console

      @debug = new DebugView
      @waitOn @append '.js-debug', @debug

    appeared: ->


  (new ExampleApp).start()


