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
	path: [type: String, default: '/']
		
PostSchema.virtual('permalink').get () ->
	l = "/permalink/#{this._id}"
	l += "/#{this.slug}" if this.slug

	return l



module.exports = mongoose.model 'Post', PostSchema