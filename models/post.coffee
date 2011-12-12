mongoose = require 'mongoose'

Schema = mongoose.Schema
ObjectId = Schema.ObjectId

PostSchema = new Schema
	title: String
	content: String
	slug: String
	created:
		type: Date
		default: Date.now()
	source: String
	path: 
		type: String
		default: '/'
	

module.exports = mongoose.model 'Post', PostSchema