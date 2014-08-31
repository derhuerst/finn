# dependencies
events			= require 'events'
Storage			= require './Storage'





# The `Plugin` class represents a single plugin.
class Plugin extends events.EventEmitter



	# make the plugin able to remember things over multiple requests
	storage = null



	constructor: () ->
		@storage = new Storage()





module.exports = Plugin