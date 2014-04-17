express = require 'express'
jade = require 'jade'
fs = require 'fs'
path = require 'path'
coffee = require 'coffee-script'
stylus = require 'stylus'
nib = require 'nib'
Future = require 'fibers/future'
Fiber = require 'fibers'

log = require('./log').bind 'Frontend', 20

futures =
  stat: Future.wrap fs.stat
  isFile: (path) ->
    future = new Future
    fs.stat path, (err, stats) ->
      future.return !err && stats.isFile()
    future
  readFile: Future.wrap fs.readFile
  #stylusRender: Future.wrap stylus.render
  stylusRender: (str, path) ->
    future = new Future
    stylus(str)
      .set('filename', path)
      #.set('compress', true)
      .use(nib())
      .render future.resolver() # Just takes (res, err) -> and throws err or returns res
    future


compileTargets =
  'js':
    'js': (data) -> data
    'coffee': (data) -> coffee.compile data.toString()
    'jade': (data) ->
      template = jade.compileClient data.toString(), {pretty: false, compileDebug: false}
      return "define(['jade.runtime'],function(jade){return #{template};});"
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
        log "#{type}: #{filename} -> #{filePath}"
        res.contentType type
        res.send handler data
        return
    res.send 404, ''


listen = (applicationPath="/", port = 3000) ->
  # This points to the directory this file is in.
  frameworkPath = path.join __dirname, '../framework'

  sourceDirectories = [applicationPath, frameworkPath]  # App files take precedence

  app = express()
  app.set 'views', frameworkPath

  # Respond to all requests using fibers
  app.use (req, res, next) -> next.future()()

  # js file handling
  app.get /^\/(.*)\.(js)$/, compiledServe sourceDirectories, compileTargets.js

  # css file handling
  app.get /^\/(.*)\.(css)$/, compiledServe sourceDirectories, compileTargets.css

  # Images
  app.get /^\/(.*)\.(png|jpg|jpeg|gif)$/, compiledServe sourceDirectories, compileTargets.images

  app.get '*', (req, res) ->
    res.type 'xhtml'
    res.render 'index.jade'

  app.listen port


module.exports.serve = (applicationPath, port) ->
  log "Serving #{applicationPath} on #{port}"
  listen applicationPath, port

