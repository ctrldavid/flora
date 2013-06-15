define [
  '$'
  'view'
  'application'
  'templates/layout'
  'templates/messagebox'
], ($, View, Application, layoutT, messageboxT) ->

  class ExampleApp extends Application
    template: layoutT
    render: ->
      @messageBox = new MessageBox
      @waitOn @append '.js-messagebox', @messageBox

    appeared: ->

  class MessageBox extends View
    template: messageboxT



  (new ExampleApp).start()


