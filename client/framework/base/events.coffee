define [
  'backbone'
], (Backbone) ->
  # This is retarded.
  class Events
    on: Backbone.Events.on
    once: Backbone.Events.once
    off: Backbone.Events.off
    trigger: Backbone.Events.trigger
    stopListening: Backbone.Events.stopListening

  return Events
