express = require 'express'
jade = require 'jade'
fs = require 'fs'
path = require 'path'
coffee = require 'coffee-script'
stylus = require 'stylus'

module.exports.listen = (applicationPath, port = 3000) ->
  app = express()
  
  frameworkPath = path.join __dirname, '../framework'

  console.log "Serving: ", frameworkPath, applicationPath

  app.set 'views', frameworkPath

  app.get /^\/(.*)\.js$/, ({params: [filename]}, res) ->
    console.log 'JS:', filename
    filePaths = []
    for locationPath in [frameworkPath, applicationPath]  # App files take precedence
      for ext in ['coffee', 'jade', 'js']
        filePath = path.join locationPath, "#{filename}.#{ext}"
        filePaths.push {ext, filePath}

    tryPath = ->
      next = filePaths.pop()
      if next
        {filePath, ext} = next
        console.log 'Trying: ', filePath
        fs.stat filePath, (err, stats) ->
          if err || not stats.isFile()
            tryPath()
          else
            fs.readFile filePath, (err, data) ->
              if err
                tryPath()
              else
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
      else
        res.send 'wat?'

    tryPath()

  app.get /^\/(.*)\.css$/, ({params: [filename]}, res) ->
    console.log 'CSS:', filename
    filePaths = []
    for locationPath in [frameworkPath, applicationPath]  # App files take precedence
      for ext in ['styl', 'css']
        filePath = path.join locationPath, "#{filename}.#{ext}"
        filePaths.push {ext, filePath}

    tryPath = ->
      next = filePaths.pop()
      if next
        {filePath, ext} = next
        console.log 'Trying: ', filePath
        fs.stat filePath, (err, stats) ->
          if err || not stats.isFile()
            tryPath()
          else
            fs.readFile filePath, (err, data) ->
              if err
                tryPath()
              else
                res.contentType 'css'
                switch ext
                  when 'css'
                    response = data
                    res.send response
                  when 'styl'
                    response = stylus.render data.toString(), (err, css)->
                      res.send css

      else
        res.send 'wat?'

    tryPath()

  app.get '*', (req, res) ->
    res.render 'index.jade'

  console.log "Listening on port #{port}"
  app.listen port
