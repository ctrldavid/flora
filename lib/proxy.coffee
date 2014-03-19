zmq = require 'zmq'
log = require('./log').bind 'Proxy', 20

# Forward messages from one port to the other.
proxy = (pubAddr, subAddr) ->
  xpub = zmq.socket 'xpub'
  xsub = zmq.socket 'xsub'
  xpub.bindSync pubAddr
  xsub.bindSync subAddr

  xsub.on 'message', -> 
    arr = Array.prototype.slice.call arguments
    log "#{subAddr} -> #{pubAddr}"
    #log "#{JSON.stringify arr.map (x)->x.toString()}"
    xpub.send arr
  xpub.on 'message', -> 
    arr = Array.prototype.slice.call arguments    
    log "#{subAddr} <- #{pubAddr}"
    #log "#{JSON.stringify arr.map (x)->x.toString()}"
    xsub.send arr
  log "Proxying traffic from #{pubAddr} to #{subAddr}"


module.exports.link = proxy