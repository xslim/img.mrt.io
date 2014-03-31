'use strict'

env = require('node-env-file')
express = require('express')
app = express()
http = require('http')
fs = require('fs')
async = require 'async'

flickr = require('./flickr')
maps = require('./maps')


if fs.existsSync(__dirname + '/.env' )
  env(__dirname + '/.env')



# For gzip compression
app.use express.compress()

# if (process.env.NODE_ENV === 'production') {
# } else {
# }

# REDIS
if process.env.REDISTOGO_URL
  conn_url = process.env.REDISTOGO_URL
  rtg   = require("url").parse(conn_url)
  redis = require("redis").createClient(rtg.port, rtg.hostname)
  redis.on "error", (err) ->
          console.log "Error ", err
  redis.auth(rtg.auth.split(":")[1])


#
# * Helpers
#

time_start =->
  process.hrtime()
time_end = (t) ->
  t = process.hrtime(t)
  t = (t[0] * 1e9 + t[1]) / 1e6
  t.toFixed(0) #3

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
# * Proxy
#

route_notfound = (res) ->
  res.send('404: Page not Found', 404)

proxyTo = (url, response, callback) ->
  t = time_start() if callback
  try
    http.get url, (res) ->
      if callback
        size = res.headers['content-length'] ? 0
        size = (size / 1024).toFixed(0)
        callback(size, time_end(t))
      res.pipe response

  catch _error
    response.writeHead 500, "Content-Type": "text/html"
    response.end url, _error.message
  
do_proxy = (req, res, resolver) ->
  if !redis
    resolver req, (url) ->
      return route_notfound(res) unless url?
      proxyTo url, res
    return
    
  req_url = req.url
  redis.hget req_url, 'url', (err, url) ->
    if url?
      redis.hincrby req_url, 'n', 1
      proxyTo url, res
    else
      resolver req, (url) ->
        return route_notfound(res) unless url?
        proxyTo url, res, (kb, ms) ->
          redis.hmset req_url, 'url', url, 'kb', kb, 'ms', ms
          
#
# * Routes
# 

# Ping
app.get "/ping", (req, res, next) ->
  res.writeHead 200, "Content-Type": "text/plain"
  res.end 'PONG'

# Index Page
app.get "/", (req, res, next) ->
  fs.readFile 'README.md', (err, data) ->
    res.writeHead 200, "Content-Type": "text/plain"
    res.end data

# REDIS
app.get "/redis/flushdb", (req, res) ->
  redis.flushdb (err, data) ->
    res.writeHead 200, "Content-Type": "text/plain"
    res.end (data || err)

app.get "/redis/keys", (req, res) ->
  
  rhgetall = (key, callback) ->
    setTimeout (->
      redis.hgetall key, (err, resp) ->
        h = {}
        h[key] = resp
        callback null, h
    ), 500
  
  redis.keys '*', (err, keys) ->
    res.writeHead 200, "Content-Type": "application/json"
    
    async.map keys, rhgetall, (err, result) ->
      res.end JSON.stringify(result)




# Test image proxy
app.get "/slim.jpg", (req, res) ->
  proxyTo "http://gravatar.com/avatar/4374a44a5a6642a24ac2975b9aa2dfe7", res


# Static Map
app.get "/map/:type?/:lat,:lon,:zoom/:size?", (req, res) ->
  type = req.param("type") ? req.query.t
  size = req.param("size") ? '500x200'
  zoom = req.param("zoom") ? 13
  
  resolver = (req, callback) ->
    url = maps.static_link(req.param("lat"), req.param("lon"), zoom, size, type)
    callback url
  do_proxy req, res, resolver
  

# Flickr
app.get "/flickr/set/:id", (req, res) ->
  set_id = req.param("id")
  flickr.getSetInfo set_id, (data) ->
    res.writeHead 200, "Content-Type": "application/json"
    res.end JSON.stringify(data)


app.get "/flickr/:id/:size?", (req, res) ->
  resolver = (req, callback) ->
    photo_id = req.param("id")
    size = req.param("size")
    flickr.getPhotoInfo photo_id, size, (data) ->
      return callback(data) unless size is 'json'
      res.writeHead 200, "Content-Type": "application/json"
      res.end JSON.stringify(data)
  
  do_proxy req, res, resolver

# Rest goes to 404
app.get "*", (req, res) ->
  res.writeHead 404
  res.end "404!"

app.listen process.env.PORT or 3000