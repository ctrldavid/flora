define [
  'backbone'
  '$'
  'view'
], (Backbone, $, View) ->

  class Application extends View
    constructor: ->
      @App = this
      @once 'appear', =>
        @waitOn new Promise (resolve, reject) -> $ -> resolve()
        @once 'appear', => @appendTo $ 'body'

      @once 'appeared', =>
        $('title').text @title if @title?
      super


    start: ->
      # Don't really need to call anything to start it :S
      # should maybe make them call append?


  return Application
