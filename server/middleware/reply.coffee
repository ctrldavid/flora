exports.Reply = (message, next) ->
  # console.log 'IN REPLY MIDDLEWARE'
  clientID = message.connectionid.toString()
  message.reply = {
    connectionid: clientID
    send: (channel, message) =>
      @log "#{@c '<-'} #{@s clientID} Reply MW #{@c channel}/#{@c message.command}. Data:#{@c JSON.stringify(message.data)}"
      # @clientPub.send ["#{channel}", "#{message.command}", "#{message.id}", "#{clientID}", "#{JSON.stringify(message.data)}"]
      # @xsend "#{channel}/#{message.command}", message
      message.channel = channel
      message.connectionid = clientID
      @xsend "ws/send", message
  }
  next()
