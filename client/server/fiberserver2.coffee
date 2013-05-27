express = require 'express'
jade = require 'jade'
fs = require 'fs'
path = require 'path'
coffee = require 'coffee-script'
stylus = require 'stylus'
Future = require 'fibers/future'
Fiber = require 'fibers'

stat = Future.wrap fs.stat
futures = 
  isFile: (path) ->
    future = new Future
    fs.stat path, (err, stats) ->
      future.return !err && stats.isFile()
    future
  readFile: Future.wrap fs.readFile
  stylusRender: Future.wrap stylus.render 


listen = (applicationPath="/", port = 3000) ->
  app = express()
  app.set 'views', ''  

  # Respond to all requests using fibers
  app.use (req, res, next) -> next.future()()

  # This points to the directory this file is in.
  frameworkPath = path.join __dirname, '../framework'

  # js file handling
  app.get /^\/(.*)\.js$/, ({params: [filename]}, res) ->
    filePaths = []
    for directory in [frameworkPath]#, applicationPath]  # App files take precedence
      for ext in ['coffee', 'jade', 'js']
        filePath = path.join directory, "#{filename}.#{ext}"
        filePaths.push {ext, filePath}

    while {filePath, ext} = filePaths.pop()
      break unless filePath?
      if futures.isFile(filePath).wait()
        data = futures.readFile(filePath).wait()
        console.log 'JS: ', filename, '->', filePath
        res.contentType 'js'
        switch ext
          when 'js'
            response = data
          when 'coffee'
            response = coffee.compile data.toString()
          when 'jade'
            template = jade.compile data.toString(), {pretty: false, client: true, compileDebug: false}
            response = "define(['vendor/jade.runtime'],function(){return #{template};});"
        res.send response
        return
    console.log 'Failed to find', filename

  app.get /^\/(.*)\.css$/, ({params: [filename]}, res) ->
    filePaths = []
    for directory in [frameworkPath]#, applicationPath]  # App files take precedence
      for ext in ['styl', 'css']
        filePath = path.join directory, "#{filename}.#{ext}"
        filePaths.push {ext, filePath}    

    while {filePath, ext} = filePaths.pop()
      break unless filePath?
      if futures.isFile(filePath).wait()
        data = futures.readFile(filePath).wait()
        console.log 'CSS:', filename, '->', filePath
        res.contentType 'css'
        switch ext
          when 'css'
            response = data
          when 'styl'
            response = futures.stylusRender(data.toString()).wait()
        res.send response
        return
    console.log 'Failed to find', filename


  # Images
  app.get /^\/(.*)\.(png|jpg|jpeg|gif)$/, ({params: [filename, ext]}, res) ->
    filePaths = []
    for directory in [frameworkPath]#, applicationPath]  # App files take precedence
      filePath = path.join directory, "#{filename}.#{ext}"
      filePaths.push {ext, filePath}    

    while {filePath, ext} = filePaths.pop()
      break unless filePath?
      if futures.isFile(filePath).wait()
        console.log 'PNG:', filename, '->', filePath
        res.sendfile filePath
        return
    console.log 'Failed to find', filename

  console.log "\n\n\nServing: ", frameworkPath, applicationPath
  app.get '*', (req, res) ->
    res.render '../framework/index.jade'

  app.listen port


listen('', 3001)