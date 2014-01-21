define [
  '$'
  'view'
  'controllers/chat'
  'templates/chat/main'
], ($, View, {ChatController}, mainT) ->
  class ChatView extends View
    template: mainT
    events: {}

    init: ->
      window.CC = new ChatController

    addreceive: (data) =>
      @append '.js-frames', new FrameView model: {frame:data, direction:"from"}

    addsend: (data) =>
      @append '.js-frames', new FrameView model: {frame:data, direction:"to"}



  {ChatView}
