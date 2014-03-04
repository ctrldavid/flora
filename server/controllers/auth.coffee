{Controller} = require '../zmqcontroller'
{Message} = require '../message'
{Reply} = require '../middleware/reply'
{Auth} = require '../middleware/auth'
uuid = require 'node-uuid'
redis = require 'redis'


# Pretty sure the client can be shared between multiple controller instances
# Although it won't be checked till way later once I have multiple instances running
# with sharding and shit
client = redis.createClient()

# Auth module
class AuthController extends Controller
  middleware: [Reply, Auth]
  constructor : ->
    super

    @on 'client', 'sharded', 'auth', 'request', (message) ->
      # @log "#{@s message.connectionid} requesting auth"

      connectionID = message.connectionid
      newUserID = uuid.v4()
      
      client.hset 'auth/c2u', connectionID, newUserID, (err) ->
        # console.log "set c2u #{connectionID} -> #{newUserID}"

      client.hset 'auth/u2c', newUserID, connectionID, (err) ->
        # console.log "set u2c #{newUserID} -> #{connectionID}"
    
      message.reply.send 'auth', {command: 'confirm', id:undefined, data:{userID: newUserID}}


    @on 'client', 'sharded', 'auth', 'rename', (message) ->
      # @log "#{@s message.connectionid} changing name"
      
      client.hset 'auth/u2n', message.Auth.userID, message.data.name, (err) ->

        # console.log "set u2n #{message.Auth.userID} -> #{message.data.name}"

      message.reply.send 'auth', {command: 'name', id:undefined, data:{userID: message.userID, name: message.data.name}}


  init: ->
    client.select 1, () =>
      @log 'Shit I should wait for this somehow...'

    @channels = {}


exports.AuthController = AuthController
