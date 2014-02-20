zmq = require 'zmq'



sub = zmq.socket 'sub'
sub.connect 'tcp://127.0.0.1:8007'
sub.subscribe ""

sub.on 'message', ->
  console.log 'sub message:', arguments

pub = zmq.socket 'pub'
pub.connect 'tcp://127.0.0.1:8507'

setInterval ->
  console.log 'sending'
  pub.send ['a', 'b']
, 1000
