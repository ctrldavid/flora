define [
  'backbone'
  '$'
  'view'
], (Backbone, $, View) ->

  class Application extends View
    start: ->
      @appendTo $ 'body'

    appear: ->
      @waitOn new Promise (resolve, reject) -> $ -> resolve()

    appeared: ->
      $('title').text @title if @title?


  return Application
