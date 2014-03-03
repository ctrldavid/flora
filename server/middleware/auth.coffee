redis = require 'redis'
client = redis.createClient()

# client.on 'error', (err) ->
#   console.log "Redis Error! [#{err}]"

# client.select 1, () ->
#   client.set 'key', 'value!', redis.print
#   client.hset 'hash', 'one', 'value', redis.print
#   client.hset 'hash', 'two', 'other', redis.print
#   client.hkeys 'hash', (err, replies) ->
#     console.log "#{replies.length} replies:"
#     for reply, i in replies
#       console.log "  #{i}: #{reply}"
#     client.quit()
# console.log 'test'
client.select 1, () ->
  console.log 'gyar... fibres?'

exports.Auth = (message, next) ->
  # console.log 'IN AUTH MIDDLEWARE'
  connectionID = message.connectionid.toString()

  client.hget 'auth/c2u', connectionID, (err, userID) ->
    # console.log 'got userID:', userID
    client.hget 'auth/u2n', userID, (err, name) ->
      # console.log 'got name:', name

      message.Auth = {
        userID
        name
      }
      next()
