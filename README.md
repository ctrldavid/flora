flora framework
---------------

frontend (the `client` folder)

it consists of a server and a bunch of client files.  the client files are a set of extensions to the backbone.js library/framework that make development slightly easier.  the server does on the fly compilation of `.coffee`, `.jade` and `.stylus` files for use with the requirejs module system.  this allows us to request files like 'view/main' and 'template/main' and have the first resolve to `view/main.coffee` and the second resolve to `template/main.jade` 

"install" the flora bin with `sudo npm link`