define [
  '$'
  'view'
  'application'
  'controllers/stem'
  'views/wsconsole'
  'views/wsdebug'
  'views/chat'
  'templates/layout'
], ($, View, Application, Stem, {ConsoleView}, {DebugView}, {ChatView}, layoutT) ->

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

      @chat = new ChatView
      @append '.js-chat', @chat

    appeared: ->


  (new ExampleApp).start()


