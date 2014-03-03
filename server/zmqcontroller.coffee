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


# Coloury shit

ANSI =
  black: '\x1B[31;0m'
  red:   '\x1B[31;1m'
  rgb: (r, g, b) -> "\x1B[38;5;#{16+r*36+g*6+b}m"
  inc: (n, m=216) -> "\x1B[38;5;#{16+1+0|n*216/m}m"   # 0| floors, n is step along from 0 to m, 216 over m scales it to 216
  ci: (n) -> ANSI.inc(parseInt(n,10)) + n + ANSI.reset
  reset: '\x1B[0m'
  colour: (r,g,b) -> (str) -> ANSI.rgb(r, g, b) + str + ANSI.reset
  randomColour: () -> ANSI.colour Math.random()*6|0, Math.random()*6|0, Math.random()*6|0
  hashColour: (msg) ->
    n = 0
    n = (n + letter.charCodeAt(0)*(index+21)) % 216 for letter, index in msg
    
    (str) -> ANSI.inc(n) + str + ANSI.reset

colourHash = {}

pad = (s, n=2) ->
  s = s.toString()
  if s.length < n then pad("0#{s}") else s
ts = timestamp = () ->
  d = new Date
  a = '/'
  b = ' '
  c = ':'
  ANSI.ci(pad d.getUTCDate()) + a + ANSI.ci(pad d.getUTCMonth()+1) + b +   # Why does getUTCMonth go 0-11? ><
    ANSI.ci(pad d.getUTCHours()) + c + ANSI.ci(pad d.getUTCMinutes()) +
    c + ANSI.ci(pad d.getUTCSeconds())






class Controller
  constructor: ->
    @middleware ?= []
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
      @log "#{@c '->'} #{@s connectionid} #{@c channel}/#{@c command}. Data:#{@c data}"
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
        # console.log "Index: #{index}, length: #{@middleware.length}"
        # console.log @middleware[index]
        if index < @middleware.length
          # console.log 'GOING BRAH'
          @middleware[index++].apply this, [message, next]
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
    @log "#{@c '<-'} #{@s message.connectionid} #{@c channel}/#{@c message.command}. Data:#{@c JSON.stringify(message.data)}"
    @serverPub.send ["#{channel}", "#{message.command}", "#{message.id}", "#{message.connectionid}", "#{JSON.stringify(message.data)}"]

  @middleware: (middleware) ->
    # Pass the request through our middleware layers
    handle = (message, fn) =>
      index = 0
      next = =>
        console.log "Index: #{index}, length: #{middleware.length}"
        console.log middleware[index]
        if index < middleware.length
          console.log 'GOING BRAH'
          middleware[index++].apply this, [message, next]
        else
          done()

      # Handle the request
      done = =>
        fn.apply this, [message]


    return (fn) => (message) => handle message, fn
        
  log: (msg) ->
    console.log "#{ts()} #{@c @constructor.name}: #{msg}"

  c: (msg) ->
    msg = msg.toString()
    colourHash[msg] = ANSI.hashColour(msg) unless colourHash[msg]?
    colourHash[msg] msg     
  s: (msg) -> @c msg.toString().substr(0,8)


exports.Controller = Controller
