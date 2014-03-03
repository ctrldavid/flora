exports.Reply = (message, next) ->
  # console.log 'IN REPLY MIDDLEWARE'
  clientID = message.connectionid.toString()
  message.reply = {
    send: (channel, message) =>
      @log "#{@c '<-'} #{@s clientID} #{@c channel}/#{@c message.command}. Data:#{@c JSON.stringify(message.data)}"
      @clientPub.send ["#{channel}", "#{message.command}", "#{message.id}", "#{clientID}", "#{JSON.stringify(message.data)}"]
  }
  next()
