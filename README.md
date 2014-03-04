flora framework
---------------

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