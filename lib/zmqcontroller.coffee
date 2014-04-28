###
  wat to dooooo.....
  Maybe websocket endpoints should be controllers? do away with the CS/SC/SS bs?

  How to do handlers... string parsing?
  general form: "channel:shard/command/subcommand/blar"
  or without sharding: "channel/command"
  "ws:channel/command"
  "chat:room/command"


  What about subcommandy stuff? should it even be allowed?
  should "ws/send" handle messages to "ws/send/chat"?

  I could just pass it directly... then the : shit won't work...



###

zmq = require 'zmq'
log = require './log'

class Controller
  constructor: ->
    @middleware ?= []

    @serverSub = zmq.socket 'sub'
    @serverSub.connect 'tcp://127.0.0.1:8000'
    
    @serverPub = zmq.socket 'pub'
    @serverPub.connect 'tcp://127.0.0.1:8500'

    @serverSub.on 'message', (path, data) =>
      data = JSON.parse "#{data}" # data comes in as a slowbuffer from ZMQ
      #@log "#{@c '->'} #{@s data.connectionid} #{@c path}. Data:#{@c JSON.stringify data}"
      @log "#{@c '->'} #{@s data.connectionid} #{@c path}."
      if @events?[path]?
        @events[path].apply this, [data]

    # @serverSub.subscribe ''  # Subscribe to everything for testing
    
    for path of @events
      @log "Subscribing to #{@c path}"
      @serverSub.subscribe path  
    
    @log @c 'initialising.'
    @init?()
    

  deconstruct: ->
    # @serverSub.disconnect 'tcp://127.0.0.1:8000'
    # @serverPub.disconnect 'tcp://127.0.0.1:8500'
    @serverSub.close()
    @serverPub.close()

  send: (path, data) ->
    #@log "#{@c '<-'} #{@c path}. Data:#{@c JSON.stringify(data)}"
    @log "#{@c '<-'} #{@c path}."
    @serverPub.send ["#{path}", "#{JSON.stringify(data)}"]

  # Static helper method for attaching middleware to handlers.
  @middleware: (arr) ->
    # Pass the request through our middleware layers
    # console.log 'wat wat MW'
    handle = (message, done) ->
      # console.log 'HANDLE'

      index = 0
      next = =>
        # console.log "Index: #{index}, length: #{arr.length}"
        # console.log arr[index]
        if index < arr.length
          # console.log 'GOING BRAH'
          # console.log JSON.stringify message
          arr[index++].apply this, [message, next]
        else
          done.apply this, [message]
      
      next.apply this, [message, next]


    return (fn) -> 
      # This function is called in the context of the class
      (message) -> 
        # This function is called in the context of the instance of the class
        handle.apply this, [message, fn]
        
  log: (msg) ->
    title = @constructor.name
    title = ' ' + title while title.length < 20

    console.log "#{log.ts()} #{@c title}: #{msg}"

  c: (msg) ->
    log.ch msg  
  s: (msg) -> 
    msg ?= ''
    @c msg.toString().substr(0,8)


exports.Controller = Controller
