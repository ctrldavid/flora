define [
  '$'
  'view'
], ($, View) ->

  class Application extends View
    start: ->
      @appendTo $ 'body'

  return Application
