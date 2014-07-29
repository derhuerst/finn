# dependencies
{EventEmitter}	= require 'events'
path			= require 'path'
walkdir			= require 'walkdir'
http			= require 'http'
readAll			= require 'readall'
Wit				= require 'wit-ai'





class Geoffrey extends EventEmitter



	log: null

	wit: null

	plugins: null

	port: null
	server: null



	constructor: (_) ->
		_ = {} if not _?

		# wit.ai connection
		@log = if _.log? then _.log else console

		# wit.ai connection
		if not _.wit?
			throw new Error 'no wit token passed'
		@wit = new Wit _.wit

		# load plugins
		@plugins = {}
		reader = walkdir (if _.plugins? then _.plugins else "#{process.env.HOME}/.geoffrey"),
			no_recurse: true
		reader.on 'directory', (file) =>
			return if /^\./.test path.basename file    # directory begins with .
			name = path.basename(file).replace '.', '-'
			try
				@plugins[name] =
					function: require file
					storage: {}
				@log.info "#{file} plugin loaded"
			catch
				@log.warning "coudn't load #{name} plugin"

		# HTTP server
		@port = if _.port? then _.port else 10000
		@listen() if not _.listen? or _.listen is true



	listen: () ->
		# plugin error callback
		onError = (request, response, error) ->
			response.status = 500
			response.end JSON.stringify
				status: 'error'
				message: error

		# plugin success callback
		onSuccess = (request, response, answer) ->
			response.status = 200
			answer.status = 'ok'
			response.end JSON.stringify answer

		# setup HTTP server
		@server = http.createServer()
		@server.on 'request', (request, response) =>
			response.setHeader 'Content-Type', 'application/json'
			readAll request, (error, question) =>
				return if error
				@query
					question: question.toString()
					error: (error) ->
						onError request, response, error
					success: (answer) ->
						onSuccess request, response, answer
		@server.listen @port
		@log.info "listening on port #{@port}"



	query: (_) ->
		# check parameters
		if not _.question?
			throw new Error 'no question passed'
		if not _.success?
			throw new Error 'no success callback passed'
		_.error = (()->) if not _.error?

		
		# plugin error callback
		onError = (error) ->
			@log.warning "'#{_.question}'\t#{error}"
			_.error error

		# plugin success callback
		onSuccess = (answer) ->
			@log.warning "'#{_.question}'\tanswered"
			_.success answer

		query =
			user_text: _.question
		@wit.analyze query, (error, response, result) =>
			# parse response
			result = JSON.parse(result).outcomes[0]
			entities = []
			for type, value of result.entities
				entities.push {type, value}

			# call plugin
			if not @plugins[result.intent]?
				return onError "no #{_.result.intent} plugin loaded"
			plugin = @plugins[result.intent]
			plugin.function _.question, entities, plugin.storage, onSuccess, onError    # pass data to plugin





module.exports = Geoffrey