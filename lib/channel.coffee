log = require('./log') #.bind 'Channel Handler', 20
fs = require 'fs'
zmq = require 'zmq'

serverSub = zmq.socket 'sub'
serverSub.connect 'tcp://127.0.0.1:8000'

serverPub = zmq.socket 'pub'
serverPub.connect 'tcp://127.0.0.1:8500'
    
deconstruct: ->
  @serverSub.close()
  @serverPub.close()


class Channel
  constructor: (@path = '') ->
    console.log "New channel with path: #{@path}"
    # serverSub.subscribe @path
    @handlers = {}

    serverSub.on 'message', (path, data) =>
      data = JSON.parse "#{data}" # data comes in as a slowbuffer from ZMQ
      #@log "#{@c '->'} #{@s data.connectionid} #{@c path}. Data:#{@c JSON.stringify data}"
      @log "#{@c '->'} #{@s data.connectionid} #{@c path}."

      if @handlers?[path]?
        handler.apply this, [data] for handler in @handlers[path]
        #@handlers[path].apply this, [data]


  deconstruct: ->
    serverSub.unsubscribe 'all the paths'

  fullpath: (path) ->
    return if @path == '' then path else @path + '/' + path

  on: (path, fnc) ->
    fullpath = @fullpath path
    serverSub.subscribe fullpath
    @handlers[fullpath] ?= []
    @handlers[fullpath].push fnc

    @log "Subscribing to #{@c fullpath}"

  send: (path, data) ->
    fullpath = @fullpath path
    #@log "#{@c '<-'} #{@c path}. Data:#{@c JSON.stringify(data)}"
    @log "#{@c '<-'} #{@c fullpath}."
    serverPub.send ["#{fullpath}", "#{JSON.stringify(data)}"]
    

  log: (msg) ->
    title = @constructor.name
    title = ' ' + title while title.length < 20

    console.log "#{log.ts()} #{@c title}: #{msg}"

  c: (msg) ->
    log.ch msg
  s: (msg) -> 
    msg ?= ''
    @c msg.toString().substr(0,8)



module.exports.load = (path) ->
  handler = null
  load = ->
    log.bind('Channel Handler', 20) "Injecting channel: #{path}"
    handler = require path
    injected = handler.load {Channel, log}


  load()