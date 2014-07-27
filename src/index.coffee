{EventEmitter} = require 'events'
readall = require 'readall'
wit = require('wit-node').wit
{readdirSync} = require 'fs'


class Geoffrey extends EventEmitter



	server: null

	scripts: null



	constructor: (options) ->
		if !options?
			options = {}

		# load scripts
		@scripts = {}
		for file in readdirSync '../scripts'    # todo: robust path
			script = file.slice 0, file.lastIndexOf '.'    # todo: use module for that?
			@scripts[script] = require path.resolve '..', 'scripts', file

		# HTTP server
		if not options.listen? or options.listen is true
			@listen()



	listen: (port) ->
		port = 10000 if not port?
		@server = http.createServer
		@server.on 'request', (request, response) ->
			response.status = 200
			response.setHeader 'Content-Type', 'application/json'
			readAll request, (question) ->    # read all stream data
				@query question, (answer) ->
					response.write JSON.stringify answer
			response.end()



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