zmq = require 'zmq'

sub = zmq.socket 'sub'
sub.connect 'tcp://127.0.0.1:8000'
sub.subscribe ''
sub.on 'message', (channel, command, msgid, connectionid, data) ->
  console.log "Pub#{msgid} from #{connectionid} on channel #{channel}. Command:#{command}. Data:#{data}"