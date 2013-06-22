uuid = require 'node-uuid'
sessions = {}

class Session
  constructor: (@ip) ->
    @id = uuid.v4()

exports.Session = Session
