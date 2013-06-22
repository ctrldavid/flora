define [
  'backbone'
  'controllers/stem'
  'events'
], (Backbone, Stem, Events) ->

  ServerUpdates = do () ->
    Objects = {}
    Stem.on 'receive-redis', (data) ->
      console.log 'Redis Update'


  class RedisModel extends Events
    constructor: (path) ->

