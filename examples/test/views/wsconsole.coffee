define [
  '$'
  'view'
  'controllers/stem'
  'templates/wsconsole'
  'templates/wsframe'
], ($, View, Stem, consoleT, frameT) ->

  class ConsoleView extends View
    template: consoleT
    events: 
      'click .js-send': 'send'
      'keydown .js-frame': (e) -> @send() if e.which == 13

    init: ->
      #@ws = new WebSocket "ws://192.168.11.17:5000/"
      #@ws = new WebSocket "ws://#{window.location.hostname}:5000/"
      #@ws.onmessage = @receive
      @stem = new Stem window.location.hostname, 5000
      console.log @stem
      @stem.on 'receive', @addreceive
      @stem.on 'send', @addsend
      console.log 'application', @application


    addreceive: (data) =>
      @append '.js-frames', new FrameView model: {frame:data, direction:"from"}

    addsend: (data) =>
      @append '.js-frames', new FrameView model: {frame:data, direction:"to"}

    send: ->
      frame = @$('.js-frame').val()
      @$('.js-frame').val ''
      @stem.send frame


  
  class FrameView extends View
    template: frameT
    className: 'frame'
    init: ->
      @$el.addClass @model.direction

    loaded: ->
      @locals.text = @model.frame
      @locals.direction = @model.direction

  {ConsoleView}