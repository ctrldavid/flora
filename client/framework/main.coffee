define [
  '$'
  'view'
  'application'
], ($, View, Application) ->

  class ExampleApp extends Application
    template: -> "<h3 style='color: white;'>Flora Example App</h3><div class='js-messages'></div>"
    render: ->
      @messageView = new MessageView
      @waitOn @append '.js-messages', @messageView

    appeared: ->
      window.setInterval =>
        @append '.js-messages', new MessageView
      , 1000

  class MessageView extends View
    tagName: 'span'
    template: (locals) ->
      "<pre style='margin:0px 8px;display:inline-block;border:solid 2px rgba(255,255,255,0.5); border-radius: 6px; color: white; padding: 1px 3px; margin: 3px;'>"+locals.message+"</pre>"

    init: ->
      @messages = [
        "Pants for everyone"
        "Yay pants"
        "Wat pants?"
        "These pants!"
      ]

    loaded: ->
      @locals.message = @messages[(Math.random()*@messages.length)|0]


  (new ExampleApp).start()


