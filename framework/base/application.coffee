define [
  'backbone'
  '$'
  'view'
], (Backbone, $, View) ->

  class Application extends View
    start: ->
      $ =>
        @appendTo $ 'body'
        $('title').text @title if @title?

  return Application
