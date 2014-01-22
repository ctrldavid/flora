zmq = require 'zmq'



class Controller
  constructor: ->
    @sub = zmq.socket 'sub'
    @sub.connect 'tcp://127.0.0.1:8000'
    @sub.subscribe @channel
    
    @pub = zmq.socket 'pub'
    @pub.bindSync 'tcp://127.0.0.1:8001'

    @sub.on 'message', (channel, command, msgid, connectionid, data) =>
      # console.log "Controller- #{msgid} from #{connectionid} on channel #{channel}. Command:#{command}. Data:#{data}"      
      message = {
        channel: "#{channel}",
        command: "#{command}",
        msgid: "#{msgid}",
        connectionid: "#{connectionid}",
        data: JSON.parse "#{data}"
      }
      @commands[command]?.apply this, [message]


    @init()

  send: (message) ->
    @pub.send ["#{@channel}", "#{message.command}", "#{message.id}", "#{message.connectionid}", "#{JSON.stringify(message.data)}"]


exports.Controller = Controller