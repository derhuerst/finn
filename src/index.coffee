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
Wit				= require 'wit-ai'





class Geoffrey extends EventEmitter



	wit: null

	scripts: null

	port: null



	constructor: (options) ->
		if !options?
			options = {}

		if not options.witToken?
			throw new Error 'no wit token passed'
		@wit = new Wit options.witToken

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
		wit.analyze {
			user_text: text
		}, (error, response, result) ->
			data = []
			result = JSON.parse result
			console.log result
			for entity in result.entities
				data.push
					type: entity.value
					value: entity.body
			callback result.intent, data





module.exports = Geoffrey