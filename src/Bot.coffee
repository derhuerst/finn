# dependencies
events			= require 'events'
fs				= require 'fs'
path			= require 'path'
logme			= require 'logme'

Parser			= require './Parser'





# A `Bot` holds all other classes together.
class Bot extends events.EventEmitter



	config: null

	# a log object
	log: null

	# the connected adapter
	adapter: null

	# the input parser
	parser: null

	# a hash of all plugins
	plugins: null



	constructor: (config) ->
		super

		# check parameters
		@config = config
		throw new Error 'no wit.ai token passed' if not config.wit?
		throw new Error 'no adapter passed' if not config.adapter?

		@log = new logme.Logme
			theme: 'smile'

		# plugins
		@plugins = {}
		fs.readdir path.join(__dirname, 'plugins'), (error, plugins) =>
			throw new Error 'couldn\'t load plugins' if error
			for file in plugins
				continue if /^\./.test file    # skip files with leading dot
				Plugin = require path.join __dirname, 'plugins', file
				plugin = new Plugin this
				@plugins[plugin.name] = plugin
				@log.info "plugin #{plugin.name} loaded"

		@adapter = new (require "./adapters/#{config.adapter}") this
		@parser = new Parser this

		# glue everything together
		@adapter.on 'request', (request) =>
			@log.debug "> `#{request.input}`"
			@parser.parse request.input
			.then (parsed) =>
				if not @plugins[parsed.plugin]?
					throw "unknown plugin #{parsed.plugin}"
				return @plugins[parsed.plugin].process parsed
			.then (response) =>
				@log.debug "< `#{response}`"
				request.respond response
			.catch (error) =>
				@log.error error
				request.error error
			.done()





module.exports = Bot