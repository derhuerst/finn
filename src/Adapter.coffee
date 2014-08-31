# dependencies
events			= require 'events'





# An adapter receives user input and sends output.
class Adapter extends events.EventEmitter



	# the name of the adapter
	name: null


	# a reference to the `Bot`
	bot: null



	constructor: (bot) ->
		@bot = bot



module.exports = Adapter