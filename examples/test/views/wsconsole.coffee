define [
  '$'
  'view'
  'controllers/stem'
  'templates/wsconsole'
], ($, View, Stem, consoleT) ->

  class ConsoleView extends View
    template: consoleT
    events: 
      'click .js-send': 'send'
      'keydown .js-data': (e) -> @send() if e.which == 13

    init: ->
      @stem = Stem

    send: ->
      channel = @$('.js-channel').val()
      data = @$('.js-data').val()
      @$('.js-data').val ''
      data.command ?= channel
      data.channel = channel
      @stem.send data

  {ConsoleView}
