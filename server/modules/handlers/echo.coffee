{Message} = require '../message'
# Echo module
class EchoHandler
  commands:
    'echo': (data, sender) ->
      sender.send new Message 'echo', {data: data.data}

  message: (msg, sender) ->
    sender.send new Message 'echo', msg.data

exports.EchoHandler = EchoHandler
