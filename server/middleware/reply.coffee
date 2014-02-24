exports.Reply = (message, next) ->
  console.log 'IN REPLY MIDDLEWARE'
  clientID = message.connectionid.toString()
  message.reply = {
    send: (channel, message) =>
      @clientPub.send ["#{channel}", "#{message.command}", "#{message.id}", "#{clientID}", "#{JSON.stringify(message.data)}"]
  }
  next()
