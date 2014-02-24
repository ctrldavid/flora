###
  wat to dooooo.....
  Maybe websocket endpoints should be controllers? do away with the CS/SC/SS bs?

  How to do handlers... string parsing?
  general form: "channel:shard/command/subcommand/blar"
  or without sharding: "channel/command"
  "ws:channel/command"
  "chat:room/command"



###


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
      console.log "Controller- #{msgid} from #{connectionid} on channel #{channel}. Command:#{command}. Data:#{data}"      
      message = {
        channel: "#{channel}",
        command: "#{command}",
        msgid: "#{msgid}",
        connectionid: "#{connectionid}",
        data: JSON.parse "#{data}"
      }


      # Pass the request through our middleware layers
      index = 0
      next = =>
        console.log "Index: #{index}, length: #{@middleware.length}"
        console.log @middleware[index]
        if index < @middleware.length
          console.log 'GOING BRAH'
          @middleware[index++](message, next)
        else
          done()

      # Handle the request
      done = =>
        if @_handlers[channel]? && @_handlers[channel][command]
          for fnc in @_handlers[channel][command]
            fnc.apply this, [message]

      # Start the process
      next()

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
