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
    post.slug = slugify(post.slug) if post.slug
  
    switch post.format
      when 'markdown', 'md'
        post.content = markdown.parse post.__content
        
      else
        post.content = post.__content


    post = _.extend new PostModel, post
    post.save()

    console.log post

    res.send id: post._id, path: urlify post.path

# Read

app.get '/permalink/:id/?:slug?', (req, res, next) ->
  PostModel.findById req.params.id, (err, doc) ->
    unless err
      res.render 'read', locals: doc
    else
      next()

app.get /^(\/.*)/, (req, res) ->
  console.log req.params[0]
  PostModel.find(path: req.params[0]).sort('created', 'descending').execFind (err, docs) ->
    
    unless docs.length is 1
      res.render 'list', locals: posts: docs
    else
      res.render 'read', locals: docs[0]

# Update
app.put /^(\/.*)/, (req, res) ->
  unless req.body.post
    res.send error: 'no post'
  else
    defaults = 
      __content: req.body.post
      format: 'markdown'
    
    if req.body.id then defaults.path = req.params[0]
    
    post = _.extend defaults, props(req.body.post)
    post.slug = slugify(post.slug) if post.slug
  
    switch post.format
      when 'markdown', 'md'
        post.content = markdown.parse post.__content
        
      else
        post.content = post.__content
    
    query = {}
    if req.body.id then query._id = req.body.id else query.path = req.params[0]

    PostModel.count query, (err, count) ->
      console.log count
      if count > 1
        res.send error: 'ambiguous, more than one post found'
      else
        PostModel.update query, post, (r,d) ->
          console.log d
        res.send id: post._id, path: urlify post.path

# Delete
app.del /^(\/.*)/, (req, res) ->
  console.log req.body

  query = {}
  if req.body.id then query._id = req.body.id else query.path = req.params[0]

  
  PostModel.count query, (err, count) ->
    if count > 1
      res.send error: 'ambiguous, more than one post found'

    else
      PostModel.remove query, (r,d) ->
      res.send status: 'done'


slugify = (t) ->
  t = t.replace /[^-a-zA-Z0-9,&\s]+/ig, ''
  #t = t.replace /-/gi, "_"
  t = t.replace /\s/gi, "-"
  
  return t
urlify = (t) ->
  t = t + "";
  t = t.replace /[^\/-a-zA-Z0-9,&\s]+/ig, ''
  #t = t.replace /-/gi, "_"
  t = t.replace /\s/gi, "-"
  t = escape(t)





app.listen 3000
console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env