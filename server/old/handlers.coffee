{ChatController} = require './controllers/chat'
{AuthController} = require './controllers/auth'
{WebsocketController} = require './controllers/websocket'

new ChatController()
new AuthController()
new WebsocketController()