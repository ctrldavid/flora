define [
  '$'
  'view'
  'application'
  'views/ping'
  'templates/layout'
], ($, View, Application, {PingView}, layoutT) ->
  class PingApp extends Application
    title: "Ping Test"
    template: layoutT
    load: ->
    render: ->
      @ping = new PingView
      @append '.js-ping', @ping

    appeared: ->


  (new PingApp).start()


