define [
  '$'
  'view'
  'controllers/auth'
  'templates/navbar'
], ($, View, {AuthController}, navbarT) ->
  class NavbarView extends View
    template: navbarT
    events:
      'change .js-nickname': 'rename'

    init: ->
      @authController = new AuthController
      @waitOn @authController.eventDeferred 'load'

    rename: ->
      @authController.changeName @$('.js-nickname').val()

  {NavbarView}
