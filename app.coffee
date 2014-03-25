'use strict'

express = require('express')
app = express()
http = require('http')
fs = require('fs')

flickr = require('./flickr')
maps = require('./maps')

# For gzip compression
app.use express.compress()

# if (process.env.NODE_ENV === 'production') {
# } else {
# }

proxyTo = (url, response) ->
  console.time url
  try
    http.get url, (res) ->
      res.pipe response

  catch _error
    response.writeHead 500,
      "Content-Type": "text/html"

    response.end url, _error.message
  console.timeEnd url

  
getJSON = (url, callback) ->
  http.get(url, (res) ->
    body = ""
    res.on "data", (chunk) ->
      body += chunk
    res.on "end", ->
      data = JSON.parse(body)
      callback data

  ).on "error", (e) ->
    console.log "getJSON - Got error: ", e

global.getJSON = getJSON

#
# * Routes
# 

# Index Page
app.get "/", (req, res, next) ->
  fs.readFile 'README.md', (err, data) ->
    res.writeHead 200, "Content-Type": "text/plain"
    res.end data


# Test image proxy
app.get "/slim.jpg", (req, res) ->
  proxyTo "http://gravatar.com/avatar/4374a44a5a6642a24ac2975b9aa2dfe7", res


# Static Map
app.get "/map/:lat,:lon,:zoom/:size", (req, res) ->
  url = maps.static_link(req.param("lat"), req.param("lon"), req.param("zoom"), req.param("size"), req.query.t)
  proxyTo url, res


# Flickr
app.get "/flickr/set/:id", (req, res) ->
  set_id = req.param("id")
  flickr.getSetInfo set_id, (data) ->
    res.writeHead 200, "Content-Type": "application/json"
    res.end JSON.stringify(data)

app.get "/flickr/:id/:size?", (req, res) ->
  photo_id = req.param("id")
  size = req.param("size")
  flickr.getPhotoInfo photo_id, size, (data) ->
    if typeof data is "string"
      proxyTo data, res
    else
      res.writeHead 200, "Content-Type": "application/json"
      res.end JSON.stringify(data)


# Rest goes to 404
app.get "*", (req, res) ->
  res.writeHead 404
  res.end "404!"

app.listen process.env.PORT or 3000