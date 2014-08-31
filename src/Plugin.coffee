# dependencies
events			= require 'events'
Storage			= require './Storage'





# The `Plugin` class represents a single plugin.
class Plugin extends events.EventEmitter



	# the name of the plugin
	name: null


	# a reference to the `Bot`
	bot: null



	constructor: (bot) ->
		@bot = bot





module.exports = Plugin