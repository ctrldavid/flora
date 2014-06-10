define [
  'backbone'
  '$'
  'view'
], (Backbone, $, View) ->

  class Application extends View
    start: ->
      # Don't really need to call anything to start it :S
      # should maybe make them call append?

    appear: ->
      @waitOn new Promise (resolve, reject) -> $ -> resolve()
      @once 'appear', => @appendTo $ 'body'

    appeared: ->
      $('title').text @title if @title?


  return Application
