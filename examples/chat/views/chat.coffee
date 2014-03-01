define [
  '$'
  'view'
  'controllers/chat'
  'controllers/auth'
  'templates/chat/main'
  'views/message'
], ($, View, {ChatController}, {AuthController}, mainT, {MessageView}) ->
  class ChatView extends View
    template: mainT
    events:
      'keydown .js-send-message': (e) -> @send() if e.which == 13

    init: ->
      @chatController = new ChatController
      @authController = new AuthController
      window.CC = @chatController
      @chatController.on 'message', @addMessage

      @chatController.once 'loaded', => @chatController.subscribe 'global'
      @authController.once 'loaded', => @authController.go()

    send: ->
      text = @$('.js-send-message').val()
      @$('.js-send-message').val ''
      @chatController.sendMessage text

    addMessage: (msg) =>
      messageView = new MessageView {model:msg}
      @append('.messages', messageView).then =>
        window.view = messageView
        @$('.messages').scrollTop messageView.el.offsetTop





  {ChatView}
