zmq = require 'zmq'

# Forward messages from one port to the other.
proxy = (pubAddr, subAddr) ->
  xpub = zmq.socket 'xpub'
  xsub = zmq.socket 'xsub'
  xpub.bindSync pubAddr
  xsub.bindSync subAddr

  xsub.on 'message', -> 
    console.log "#{subAddr} -> #{pubAddr}"
    xpub.send Array.prototype.slice.call arguments
  xpub.on 'message', -> 
    console.log "#{pubAddr} -> #{subAddr}"
    xsub.send Array.prototype.slice.call arguments

# Server to server communication goes over this pair:
console.log 'Starting SS Proxy. XPUB:8000, XSUB:8500'
proxy 'tcp://127.0.0.1:8000', 'tcp://127.0.0.1:8500'


# Client to server communication
console.log 'Starting CS Proxy. XPUB:6000, XSUB:6500'
proxy 'tcp://127.0.0.1:6000', 'tcp://127.0.0.1:6500'


# Server to client 
console.log 'Starting SC Proxy. XPUB:7000, XSUB:7500'
proxy 'tcp://127.0.0.1:7000', 'tcp://127.0.0.1:7500'


console.log 'All proxies started.'