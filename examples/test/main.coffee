define [
  '$'
  'view'
  'application'
  'templates/layout'
  'templates/messagebox'
], ($, View, Application, layoutT, messageboxT) ->

  class ExampleApp extends Application
    title: "Test page"
    template: layoutT
    render: ->
      @messageBox = new MessageBox
      @waitOn @append '.js-messagebox', @messageBox

    appeared: ->

  class MessageBox extends View
    template: messageboxT



  (new ExampleApp).start()


