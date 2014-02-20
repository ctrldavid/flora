{Controller} = require '../zmqcontroller'
{Message} = require '../message'
uuid = require 'node-uuid'


# Auth module
class AuthHandler extends Controller
  constructor : ->
    super

    @on 'client', 'sharded', 'auth', 'request', (client, message) ->
      console.log "#{message.connectionid} requesting auth"
      client.send 'auth', {command: 'confirm', id:undefined, data:{userID: uuid.v4()}}


  init: ->
    @channels = {}

x = new AuthHandler

exports.AuthHandler = AuthHandler
