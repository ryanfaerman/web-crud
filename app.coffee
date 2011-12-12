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

# Create

app.post '/foo', (req, res) ->
  console.log req.body
  res.send 'foo'

app.post /^(\/.*)/, (req, res) ->
  console.log req.body  
  unless req.body.post
    res.send error: 'no post'
  else
    defaults = 
      __content: req.body.post
      format: 'markdown'
      path: req.params[0]

    post = _.extend defaults, props(req.body.post)
  
    switch post.format
      when 'markdown', 'md'
        post.content = markdown.parse post.__content
        post.slug = markdown.parse post.slug if post.slug
      else
        post.content = post.__content


    post = _.extend new PostModel, post
    post.save()

    console.log post

    res.send id: post._id, path: urlify post.path

# Read
app.get /^(\/.*)/, (req, res) ->
  console.log req.params[0]
  PostModel.find(path: req.params[0]).sort('created', 'descending').execFind (err, docs) ->
    
    unless docs.length is 1

      res.render 'list', locals: posts: docs
    else
      res.render 'read', locals: docs[0]

# Update

# Delete



app.get '/:id/?:slug?', (req, res) ->
  PostModel.findById req.params.id, (err, doc) ->
    console.log doc
    res.render 'read', locals: doc

app.post '/:url', (req, res) ->
  status = create req
  res.send status

create = (req)->
  

slugify = (t) ->
  t = t.replace /[^-a-zA-Z0-9,&\s]+/ig, ''
  #t = t.replace /-/gi, "_"
  t = t.replace /\s/gi, "-"
  
  return t
urlify = (t) ->
  t = t.replace /[^\/-a-zA-Z0-9,&\s]+/ig, ''
  #t = t.replace /-/gi, "_"
  t = t.replace /\s/gi, "-"
  t = escape(t)





app.listen 3000
console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env