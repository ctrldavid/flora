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

compileTargets = 
  'js':
    'js': (data) -> data
    'coffee': (data) -> coffee.compile data.toString()
    'jade': (data) ->
      template = jade.compile data.toString(), {pretty: false, client: true, compileDebug: false}
      return "define(['vendor/jade.runtime'],function(){return #{template};});"
  'css':
    'css': (data) -> data
    'styl': (data) -> futures.stylusRender(data.toString()).wait()
  'images':
    'png': (data) -> data
    'jpg': (data) -> data
    'jpeg': (data) -> data
    'gif': (data) -> data

compiledServe = (dirs, exts) ->
  ({params: [filename, type]}, res) ->
    for directory in dirs
      for ext, handler of exts
        filePath = path.join directory, "#{filename}.#{ext}"
        #console.log "Trying #{filePath}"
        continue unless futures.isFile(filePath).wait()
        data = futures.readFile(filePath).wait()
        console.log "#{type}: #{filename} -> #{filePath}"
        res.contentType type
        res.send handler data
        return
    res.send 404, ''


listen = (applicationPath="/", port = 3000) ->
  # This points to the directory this file is in.
  frameworkPath = path.join __dirname, '../framework'

  sourceDirectories = [frameworkPath, applicationPath]  # App files take precedence

  app = express()
  app.set 'views', ''  

  # Respond to all requests using fibers
  app.use (req, res, next) -> next.future()()

  # js file handling
  app.get /^\/(.*)\.(js)$/, compiledServe sourceDirectories, compileTargets.js

  # css file handling
  app.get /^\/(.*)\.(css)$/, compiledServe sourceDirectories, compileTargets.css

  # Images
  app.get /^\/(.*)\.(png|jpg|jpeg|gif)$/, compiledServe sourceDirectories, compileTargets.images

  # app.get /^\/(.*)\.(png|jpg|jpeg|gif)$/, ({params: [filename, ext]}, res) ->
  #   filePaths = []
  #   for directory in [frameworkPath]#, applicationPath]  # App files take precedence
  #     filePath = path.join directory, "#{filename}.#{ext}"
  #     filePaths.push {ext, filePath}    

  #   while {filePath, ext} = filePaths.pop()
  #     break unless filePath?
  #     if futures.isFile(filePath).wait()
  #       console.log 'PNG:', filename, '->', filePath
  #       res.sendfile filePath
  #       return
  #   console.log 'Failed to find', filename

  console.log "\n\n\nServing: ", frameworkPath, applicationPath
  app.get '*', (req, res) ->
    res.render '../framework/index.jade'

  app.listen port


listen('', 3001)