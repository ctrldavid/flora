flora framework
---------------

frontend (the `client` folder)

it consists of a server and a bunch of client files.  the client files are a set of extensions to the backbone.js library/framework that make development slightly easier.  the server does on the fly compilation of `.coffee`, `.jade` and `.stylus` files for use with the requirejs module system.  this allows us to request files like 'view/main' and 'template/main' and have the first resolve to `view/main.coffee` and the second resolve to `template/main.jade` 

"install" the flora bin with `sudo npm link`

Redis setup:
Latest ver from: http://redis.io/download
cd tmp
wget http://redis.googlecode.com/files/redis-2.6.13.tar.gz
tar xzf redis-2.6.13.tar.gz
redis-2.6.13
make

link binaries with
ln -s ~/tmp/redis-2.6.13/src/redis-server /usr/local/bin/redis-server
ln -s ~/tmp/redis-2.6.13/src/redis-cli /usr/local/bin/redis-cli
ln -s ~/tmp/redis-2.6.13/src/redis-benchmark /usr/local/bin/redis-benchmark

