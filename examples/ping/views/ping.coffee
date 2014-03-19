define [
  '$'
  'view'
  'controllers/ping'
  'templates/ping'
], ($, View, {PingController}, pingT) ->
  class PingView extends View
    template: pingT

    init: ->  
      @pingController = new PingController()
      @waitOn @pingController.eventDeferred 'load'

    appeared: ->
      @pingController.on 'update', ({ping}) =>        
        @$('.js-text').text "#{ping} ms"
        window.setTimeout => 
          @pingController.request()
        , 250
      
      @pingController.request()

  {PingView}
