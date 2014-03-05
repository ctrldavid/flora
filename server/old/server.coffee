ws = require 'ws'

uuid = require 'node-uuid'

zmq = require 'zmq'

pub = zmq.socket 'pub'
pub.connect 'tcp://127.0.0.1:6500'



ANSI =
  black: '\x1B[31;0m'
  red:   '\x1B[31;1m'
  rgb: (r, g, b) -> "\x1B[38;5;#{16+r*36+g*6+b}m"
  inc: (n, m=216) -> "\x1B[38;5;#{16+0|n*216/m}m"   # 0| floors, n is step along from 0 to m, 216 over m scales it to 216
  ci: (n) -> ANSI.inc(parseInt(n,10)) + n + ANSI.reset
  reset: '\x1B[0m'
  colour: (r,g,b) -> (str) -> ANSI.rgb(r, g, b) + str + ANSI.reset
  randomColour: () -> ANSI.colour Math.random()*6|0, Math.random()*6|0, Math.random()*6|0



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

class Client
  constructor: (@socket) ->
    @ip = @socket._socket.remoteAddress
    @session = {id:uuid.v4()}
    @colour = ANSI.randomColour()
    console.log "#{ts()} New connection with IP #{@ip} and session #{@colour @session.id}"

    @socket.on 'message', (msg) =>
      message = JSON.parse msg
      console.log "#{ts()} #{@pretty()} on [#{message.channel}] with id [#{message.id}]: [#{message.command}]. data:#{JSON.stringify(message.data)}"
      pub.send ["#{message.channel}", "#{message.command}", "#{message.id}", "#{@session.id}", "#{JSON.stringify(message.data)}"]

    @socket.on 'close', () =>
      console.log "#{ts()} Disconnect from #{@pretty()}.",arguments

  pretty: -> @colour @session.id.match(/^.{8}/)[0]

  send: (msg) ->
    try 
      @socket.send JSON.stringify msg
    catch error
      console.log 'shit son it is closed'
      
    

clients = {}
server = new ws.Server port: 5000
server.on 'connection', (socket) ->
  c = new Client socket
  clients[c.session.id] = c


sub = zmq.socket 'sub'
sub.connect 'tcp://127.0.0.1:7000'
sub.subscribe ''
sub.on 'message', (channel, command, id, connectionid, data) ->
  console.log "ZMQ: #{channel}:#{command} -> #{connectionid}"
  clients[connectionid.toString()]?.send {channel:channel.toString(), command:command.toString(), id:id.toString(), data:data.toString()}

console.log 'Server started.'

