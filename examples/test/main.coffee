define [
  '$'
  'view'
  'application'
  'views/wsconsole'
  'templates/layout'
], ($, View, Application, {ConsoleView}, layoutT) ->

  class ExampleApp extends Application
    title: "Test page"
    template: layoutT
    render: ->
      @console = new ConsoleView
      @waitOn @append '.js-console', @console

    appeared: ->


  (new ExampleApp).start()


