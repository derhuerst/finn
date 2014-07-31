# dependencies
events			= require 'events'
fs				= require 'fs'
path			= require 'path'
wit				= require 'wit-ai'
noop			= ()->

Adapter			= require './Adapter'
Plugin			= require './Plugin'





# The main `Bot` class holding all other classes together. User input will be delegated to plugins here.
class Bot extends events.EventEmitter



	# the connected adapter
	adapter: null

	# the wit.ai client
	wit: null

	# all plugins
	plugins: null

	# a log object
	log: null



	constructor: (options) ->

		# wit
		if not options.wit?
			throw new Error 'no wit.ai client passed'
		@wit = new wit options.wit

		# plugins
		@plugins = if options.plugins? then options.plugins else {}

		# log
		@log = if options.log? then options.log else console



	addPlugins: (aPath) ->
		# check parameters
		if not aPath?
			throw new Error 'no plugins path passed'

		# walk directory
		fs.readdir aPath, (error, plugins) =>
			throw new Error 'couldn\'t load plugins' if error
			for plugin in plugins
				# load plugin
				generator = require path.join aPath, plugin
				PluginClass = generator Plugin    # call generator with base class `Plugin`
				@plugins[plugin] = new PluginClass this
				@log.info "plugin #{plugin} added"


	addAdapter: (aPath) ->
		# check parameters
		if not aPath?
			throw new Error 'no adapter path passed'

		adapter = path.basename aPath

		# load adapter
		generator = require aPath
		AdapterClass = generator Adapter    # call generator with base class `Adapter`
		@adapter = new AdapterClass this
		@log.info "adapter #{adapter} added"



	query: (question, success, error) ->
		# check parameters
		if not question?
			throw new Error 'no question passed'
		if not success?
			throw new Error 'no success callback passed'
		error = noop if not error?

		# prepare callbacks
		onSuccess = (answer) =>
			@log.debug "'#{question}'", 'answered'
			answer.status = 'ok'
			success answer
		onError = (aError) =>
			@log.error "'#{question}'", "error: '#{aError}'"
			error aError

		# call wit.ai client
		query =
			user_text: question
		@wit.analyze query, (error, response, result) =>
			# parse response
			result = JSON.parse(result).outcomes[0]
			entities = []
			for type, value of result.entities
				entities.push {type, value}
			command = result.intent

			# call plugin
			if not @plugins[command]?
				return onError "no #{command} plugin loaded"
			plugin = @plugins[command]
			plugin.query question, entities, plugin.storage, onSuccess, onError    # pass data to plugin





module.exports = Bot