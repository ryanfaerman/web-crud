express = require 'express'
mongoose = require 'mongoose'
props = require 'props'
config = require './config'
_ = require 'underscore'
markdown = require 'markdown'

app = module.exports = express.createServer()

app.configure ->
  app.set "views", __dirname + "/views"
  app.set "view engine", "mustache"
  app.register ".mustache", require("stache")

  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static(__dirname + "/public")

app.configure "development", ->
  app.use express.errorHandler(
    dumpExceptions: true
    showStack: true
  )

app.configure "production", ->
  app.use express.errorHandler()

app.dynamicHelpers 
  site_title: (req, res) ->
    config.title

mongoose.connect "mongodb://#{config.host}/#{config.db}"
PostModel = require './models/post'

app.get '/', (req, res) ->
  PostModel.find().sort('created', 'descending').execFind (err, docs) ->
    console.log docs
    res.render 'list', locals: posts: docs 

app.get '/:id/?:slug?', (req, res) ->
  PostModel.findById req.params.id, (err, doc) ->
    console.log doc
    res.render 'read', locals: doc

app.post '/create', (req, res) ->
  unless req.body.post
    console.log "empty!"
  else
    defaults = 
      __content: req.body.post
      format: 'markdown'

    post = _.extend defaults, props(req.body.post)
  
    post.slug = slugify post.slug

    console.log post

    switch post.format
      when 'markdown', 'md'
        post.content = markdown.parse post.__content
      else
        post.content = post.__content

    post = _.extend new PostModel, post
    post.save()

    res.send id: post._id



slugify = (t) ->
  t = t.replace /[^-a-zA-Z0-9,&\s]+/ig, ''
  t = t.replace /-/gi, "_"
  t = t.replace /\s/gi, "-"
  
  return t


dnode = require 'dnode'
server = dnode(create: (text, cb) ->
  defaults = 
    __content: text
    format: 'markdown'

  post = _.extend defaults, props(text)

  post.slug = slugify post.slug

  switch post.format
    when 'markdown', 'md'
      post.content = markdown.parse post.__content
    else
      post.content = post.__content

  post = _.extend new PostModel, post
  post.save()

  cb post._id

)
server.listen 5050




app.listen 3000
console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env