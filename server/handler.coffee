argv = require('minimist')(process.argv.slice(2)) # Don't parse the first 2 args :P

for path in argv._
  console.log "\nLoading #{path}"
  module = require path
  for controller of module
    new module[controller]


console.log '\n------------------\nAll controllers loaded.\n'