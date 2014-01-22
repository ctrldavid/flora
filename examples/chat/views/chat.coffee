define [
  '$'
  'view'
  'controllers/chat'
  'templates/chat/main'
], ($, View, {ChatController}, mainT) ->
  class ChatView extends View
    template: mainT
    events:
      'keydown .js-send-message': (e) -> @send() if e.which == 13

    init: ->
      @ChatController = new ChatController
      window.CC = @ChatController
      @ChatController.on 'message', @addMessage

      @ChatController.once 'loaded', => @ChatController.subscribe 'global'

    send: ->
      text = @$('.js-send-message').val()
      @$('.js-send-message').val ''
      @ChatController.sendMessage text

    addMessage: (msg) =>
      message = $("<div></div>").addClass("message").text(msg.text);
      @$('.messages').append message
      @$('.messages').scrollTop @$('.messages').height()




  {ChatView}
