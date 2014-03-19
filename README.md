flora framework
---------------

to get it all working:

* clone the repo  
    `git clone blarblar/flora.git`
* install dependencies  
    `npm install`
* put the flora binary somewhere in the path  
    `npm link` or `sudo npm link`

To serve frontend files for development:  
    `flora [--port=3777] --frontend=path/to/public`  
    or  
    `flora [--port=3777] -f path/to/public`


To start the zmq proxy:  
    `flora --proxy`  
    or  
    `flora -p`

To start controller[s]:  
    `flora --controller=path/controllera [--controller=path/controllerb]`  
    or  
    `flora -c path/controllera [-c path/controllerb]`

Or combine them all  
    `flora -p --port=3001 -f examples/chat -c base/controllers/auth.coffee -c base/controllers/chat.coffee -c base/controllers/ping.coffee -c base/controllers/websocket.coffee`



Other dependencies:
===================

ZMQ stuff
---------
zmq bindings for node are old, don't support v4.
`wget http://download.zeromq.org/zeromq-3.2.4.tar.gz`
`apt-get install libtool autoconf automake uuid-dev`

go into the dir.
`./configure`
`make install`
`ldconfig`



Redis stuff
-----------

Latest ver from: http://redis.io/download
cd tmp
wget http://redis.googlecode.com/files/redis-2.6.13.tar.gz
tar xzf redis-2.6.13.tar.gz
cd redis-2.6.13
make

link binaries with
ln -s ~/tmp/redis-2.6.13/src/redis-server /usr/local/bin/redis-server
ln -s ~/tmp/redis-2.6.13/src/redis-cli /usr/local/bin/redis-cli
ln -s ~/tmp/redis-2.6.13/src/redis-benchmark /usr/local/bin/redis-benchmark





old stuff from before re-org
============================

frontend (the `client` folder)
-----------------------------

it consists of a server and a bunch of client files.  the client files are a set of extensions to the backbone.js library/framework that make development slightly easier.  the server does on the fly compilation of `.coffee`, `.jade` and `.stylus` files for use with the requirejs module system.  this allows us to request files like 'view/main' and 'template/main' and have the first resolve to `view/main.coffee` and the second resolve to `template/main.jade` 

"install" the flora bin with `sudo npm link`

Redis setup:
Latest ver from: http://redis.io/download
cd tmp
wget http://redis.googlecode.com/files/redis-2.6.13.tar.gz
tar xzf redis-2.6.13.tar.gz
cd redis-2.6.13
make

link binaries with
ln -s ~/tmp/redis-2.6.13/src/redis-server /usr/local/bin/redis-server
ln -s ~/tmp/redis-2.6.13/src/redis-cli /usr/local/bin/redis-cli
ln -s ~/tmp/redis-2.6.13/src/redis-benchmark /usr/local/bin/redis-benchmark


backend (the `server` folder)
-----------------------------
Controller all the things except the things that are middlewares.
To start a controller run

    coffee handler.coffee [path/to/controller] [path/to/othercontroller]...


So atm I run 

    coffee handler.coffee ./controllers/chat.coffee ./controllers/auth.coffee ./controllers/websocket.coffee


Shit doesn't work without the proxy set up:

    coffee proxy.coffee

    

ZMQ stuff
---------
zmq bindings for node are old, don't support v4.
`wget http://download.zeromq.org/zeromq-3.2.4.tar.gz`
`apt-get install libtool autoconf automake uuid-dev`

go into the dir.
`./configure`
`make install`
`ldconfig`



scratch
---------
new fs?

flora
 |_bin (combined)
 |_lib (helper for bin)
 |_framework (backbone stuff)
 |_base (handlers and shit)
 | |_controllers
 | |_middleware
 |_examples


packages
{
  "name": "flora-ws",
  "version": "0.0.0",
  "description": "Flora web server",
  "bin": {
    "flora": "./bin/flora"
  },
  "dependencies": {
    "jade": "~0.27.7",
    "fibers": "~0.6.9",
    "stylus": "~0.31.0",
    "coffee-script": "~1.4.0",
    "express": "~3.0.4",
    "q": "~0.8.12",
    "nib": "~0.9.1",
    "optimist": "~0.5.2"
  }
}


{
  "name": "server",
  "version": "0.0.0",
  "description": "ERROR: No README.md file found!",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "repository": "",
  "author": "",
  "license": "BSD",
  "dependencies": {
    "redis": "~0.8.3",
    "fibers": "~1.0.1",
    "node-uuid": "~1.4.0",
    "ws": "~0.4.25",
    "zmq": "~2.5.1",
    "minimist": "0.0.8"
  }
}
