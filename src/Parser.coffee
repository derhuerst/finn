# dependencies
Q				= require 'q'
WitClient		= require 'wit-ai'





# The `Parser` parses all user input.
class Parser



	# a reference to the `Bot`
	bot: null

	# wit.ai client
	client: null



	constructor: (bot) ->
		@bot = bot

		@client = new WitClient @bot.config.wit



	parse: (input) ->
		return @client.request input
		.then (outcome) =>
			outcome = outcome[0]
			outcome.input = input
			intent = outcome.intent.split '_'
			outcome.plugin = intent[0]
			outcome.intent = intent[intent.length - 1]
			if outcome.confidence < 0.5
				@bot.warning "low confidence (#{outcome.confidence})"
			return outcome





module.exports = Parser