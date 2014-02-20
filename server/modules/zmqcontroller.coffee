zmq = require 'zmq'

class Controller
  constructor: ->
    @clientSub = zmq.socket 'sub'
    @clientSub.connect 'tcp://127.0.0.1:6000'
    
    @clientPub = zmq.socket 'pub'
    @clientPub.connect 'tcp://127.0.0.1:7500'

    @serverSub = zmq.socket 'sub'
    @serverSub.connect 'tcp://127.0.0.1:8000'
    
    @serverPub = zmq.socket 'pub'
    @serverPub.connect 'tcp://127.0.0.1:8500'


    @_handlers = {}

    @clientSub.on 'message', (channel, command, msgid, connectionid, data) =>
      # console.log "Controller- #{msgid} from #{connectionid} on channel #{channel}. Command:#{command}. Data:#{data}"      
      message = {
        channel: "#{channel}",
        command: "#{command}",
        msgid: "#{msgid}",
        connectionid: "#{connectionid}",
        data: JSON.parse "#{data}"
      }

      clientID = connectionid.toString()
      client = {
        id: clientID
        send: (channel, message) =>
          @clientPub.send ["#{channel}", "#{message.command}", "#{message.id}", "#{clientID}", "#{JSON.stringify(message.data)}"]
      }

      #@commands[command]?.apply this, [message]
      if @_handlers[channel]? && @_handlers[channel][command]
        for fnc in @_handlers[channel][command]
          fnc.apply this, [client, message]


    @init()

  on: (network, sharding, channel, command, fnc) ->
    socket = (if network == 'client' then @clientSub else @serverSub)
    socket.subscribe channel
    @_handlers[channel] ?= {}
    @_handlers[channel][command] ?= []
    @_handlers[channel][command].push fnc



  send: (channel, message) ->
    @serverPub.send ["#{channel}", "#{message.command}", "#{message.id}", "#{message.connectionid}", "#{JSON.stringify(message.data)}"]


exports.Controller = Controller
