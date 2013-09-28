redis = require 'redis'
client = redis.createClient()

client.on 'error', (err) ->
  console.log "Error! [#{err}]"

# Mess around on DB:9 instead of dirtying 0
client.select 9, () ->
  client.set 'key', 'value!', redis.print
  client.hset 'hash', 'one', 'value', redis.print
  client.hset 'hash', 'two', 'other', redis.print
  client.hkeys 'hash', (err, replies) ->
    console.log "#{replies.length} replies:"
    for reply, i in replies
      console.log "  #{i}: #{reply}"
    client.quit()
console.log 'test'


class RedisObject
  constructor: (@id, @client) ->
    @subscribers = []
    @read()

  subscribe: (sender) ->
    @subscribers.push sender

  read: ->
    @client.hgetall hid @id
    @client.lrange lid 0, -1
    
  toJSON: ->
    "{}"


class RedisHandler
  constructor: () ->
    @paths = {}
    @client = redis.createClient()
    @client.select 9

  commands:
    'subscribe': (message, sender) ->
      @paths[message.id] ?= new RedisObject message.id, @client
      @paths[message.id].subscribe sender
      sender.send {channel: 'redis', command: 'info', reply: message.reply, message: "Successfully subscribed to redis object #{message.id}"}
      sender.send {channel: 'redis', command: 'sync', reply: message.reply, message: @paths[message.id].toJSON()}

    'set': (message, sender) ->
      for subscriber in @paths[message.id]
        subscriber.send {channel: 'redis', command: 'set', id: message.id, data:{key: message.data.key, value: message.data.value}}

exports.RedisHandler = RedisHandler

