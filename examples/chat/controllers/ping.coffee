define [
  'controller'
], (Controller) ->

  class PingController extends Controller
    channels: 
      ping:
        pong: (data) ->          
          diff = new Date - @lastPing
          console.log "Ping update: #{diff}ms", data
          @trigger 'update', {ping:diff}

    init: ->
      @history = []

    request: ->
      console.log 'Requesing ping'
      @lastPing = new Date
      @send 'ping', 'ping', {}


      

  return {PingController}
