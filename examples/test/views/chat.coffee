define [
  '$'
  'view'
  'controllers/chat'
  'models/redis_model'
  'templates/chat/main'
  'templates/wsframe'
], ($, View, {ChatController}, RM, mainT, frameT) ->
  window.RM = RM
  class ChatView extends View
    template: mainT
    events: {}

    init: ->
      window.CC = new ChatController

    addreceive: (data) =>
      @append '.js-frames', new FrameView model: {frame:data, direction:"from"}

    addsend: (data) =>
      @append '.js-frames', new FrameView model: {frame:data, direction:"to"}

  class FrameView extends View
    template: frameT
    className: 'frame'
    init: ->
      @$el.addClass @model.direction

    loaded: ->
      @locals.text = JSON.stringify(@model.frame, null, '  ')#.replace /{|}/g, ''
      @locals.direction = @model.direction

    # attach: (methods) -> methods.prepend

  {ChatView}
