mongoose = require 'mongoose'

Schema = mongoose.Schema
ObjectId = Schema.ObjectId

PostSchema = new Schema
	title: String
	content: String
	created:
		type: Date
		default: Date.now()
	source: String
	slug:
		type: String
		sparse: true

module.exports = mongoose.model 'Post', PostSchema