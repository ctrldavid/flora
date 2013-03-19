define [
  '$'
  'view'
], ($, View) ->

  class Application extends View
    start: ->
      @appendTo $ 'body'
      $('title').text @title if @title?

  return Application
