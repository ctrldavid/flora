define [
  '$'
  'view'
  'controllers/auth'
  'controllers/ping'
  'templates/navbar'
], ($, View, {AuthController}, {PingController}, navbarT) ->
  class NavbarView extends View
    template: navbarT
    events:
      'change .js-nickname': 'rename'

    init: ->
      @authController = new AuthController
      @waitOn @authController.eventDeferred 'load'
    
      @pingController = new PingController()

    appeared: ->
      @pingController.on 'update', ({ping}) =>        
        @$('.js-ping').text "#{ping}ms"
        if (ping < 100)
          col = 'rgba(0,255,0,1.0)'
        else if (ping > 1000)
          col = 'rgba(255,0,0,1.0)'
        else
          ratio = (ping - 100) / (1000-100)
          col = "rgba(#{Math.floor(ratio*255)},#{Math.floor((1-ratio)*255)},0,1.0)"
        @$('.js-ping').css {color:col}
      
      window.setInterval => 
        @pingController.request()
      , 5000
      @pingController.request()

    rename: ->
      @authController.changeName @$('.js-nickname').val()

  {NavbarView}
