define [
  '$'
  'view'
  'controllers/stem'
  'templates/wsdebug'
  'templates/wsframe'
], ($, View, Stem, debugT, frameT) ->

  class DebugView extends View
    template: debugT
    events: {}

    init: ->
      @stem = Stem
      @stem.on 'receive', @addreceive
      @stem.on 'send', @addsend

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

  {DebugView}
