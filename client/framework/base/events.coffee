define [
  '$'
  'backbone'
], ($, Backbone) ->
  # This is retarded.
  class Events
    on: Backbone.Events.on
    once: Backbone.Events.once
    off: Backbone.Events.off
    trigger: Backbone.Events.trigger
    stopListening: Backbone.Events.stopListening
    # Helper method for turning an event into a deferred that can be waited on.
    eventDeferred: (evt) ->
      dfd = $.Deferred()
      @once evt, dfd.resolve
      dfd.promise()

  return Events
