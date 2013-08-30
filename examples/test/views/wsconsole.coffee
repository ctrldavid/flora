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
      'click .js-go': () -> window.setInterval echo, 0

    init: ->
      @stem = Stem

    send: ->
      channel = @$('.js-channel').val()
      data = @$('.js-data').val()
      @$('.js-data').val ''
      @stem.send {data, channel, command:channel}

  window.echo = () -> Stem.send {data:'test', channel:'echo', command:'echo'}
  {ConsoleView}
