# dependencies
events			= require 'events'





# The `Plugin` class represents a single plugin.
class Plugin extends events.EventEmitter



	# make the plugin able to remember thing along requests
	storage = null



	constructor: () ->
		@storage = {}



	query: (question, entities, success, error) ->





module.exports = Plugin