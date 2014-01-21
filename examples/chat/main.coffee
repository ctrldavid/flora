define [
  '$'
  'view'
  'application'
  'views/chat'
  'templates/layout'
], ($, View, Application, {ChatView}, layoutT) ->

  class ChatApp extends Application
    title: "Chat Test"
    template: layoutT
    load: ->
    render: ->
      @chat = new ChatView
      @append '.js-chat', @chat

    appeared: ->


  (new ChatApp).start()


