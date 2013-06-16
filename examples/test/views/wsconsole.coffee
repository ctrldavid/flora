define [
  '$'
  'view'
  'templates/wsconsole'
  'templates/wsframe'
], ($, View, consoleT, frameT) ->

  class ConsoleView extends View
    template: consoleT
    events: 
      'click .js-send': 'send'
      'keydown .js-frame': (e) -> @send() if e.which == 13

    init: ->
      #@ws = new WebSocket "ws://192.168.11.17:5000/"
      @ws = new WebSocket "ws://#{window.location.hostname}:5000/"
      @ws.onmessage = @receive

    receive: ({data}) =>
      @append '.js-frames', new FrameView model: {frame:data, direction:"from"}

    send: ->
      frame = @$('.js-frame').val()
      @$('.js-frame').val ''
      @ws.send frame
      @append '.js-frames', new FrameView model: {frame, direction: "to"}

  
  class FrameView extends View
    template: frameT
    className: 'frame'
    init: ->
      @$el.addClass @model.direction

    loaded: ->
      @locals.text = @model.frame
      @locals.direction = @model.direction

  {ConsoleView}