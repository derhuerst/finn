# geoffrey
# goeffrey is a Siri-like personal assistant running on node.js.
# v0.2.0





# dependencies
{EventEmitter}	= require 'events'
path			= require 'path'
findit			= require 'findit'
log				= require 'obs-log'
http			= require 'http'
readAll			= require 'readall'
wit				= require('wit-node').wit    # bug in the wit-node package; todo: create pull request





class Geoffrey extends EventEmitter



	witToken: null

	scripts: null

	port: null



	constructor: (options) ->
		if !options?
			options = {}

		if options.witToken?
			@witToken = options.witToken
		else
			throw new Error 'no wit token passed'

		options.scripts = path.resolve if options.scripts? then options.scripts else "#{__dirname}/../scripts"

		@port = if options.port? then options.port else 10000

		# load scripts
		@scripts = {}
		reader = findit options.scripts
		reader.on 'file', (file) =>
			file = path.relative options.scripts, file
			if (path.extname file) is '.coffee'
				log "using script #{file}"
				script = path.basename().replace '.', '-'
				@scripts[script] = require path.resolve options.scripts, file

		# HTTP server
		if not options.listen? or options.listen is true
			@listen()



	listen: (port) ->
		@server = http.createServer()
		@server.on 'request', (request, response) =>
			response.status = 200
			response.setHeader 'Content-Type', 'application/json'
			readAll request, (error, question) =>    # read all stream data
				@query question.toString(), (answer) ->
					response.end JSON.stringify answer
		@server.listen @port
		log "server listening on port #{@port}"



	query: (text, callback) ->
		@_queryWit text, (command, data) ->
			callback @scripts[command] data



	_queryWit: (text, callback) ->
		wit.token = @witToken
		# we need to set the token every time because of a bug in the wit-node package; see https://github.com/modeset/wit-node/pull/3.
		request = wit.message text
		request.then (result) ->
			data = []
			for entity in result.entities
				data.push
					type: entity.value
					value: entity.body
			callback result.intent, data





module.exports = Geoffrey