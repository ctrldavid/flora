# Need a common signature for messages. Fairly simple wrapper
class Message
  constructor: (@channel, @data) ->

exports.Message = Message

