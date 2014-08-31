# dependencies
http			= require 'http'

Adapter			= require '../Adapter'
Request			= require '../Request'





class HTTPRequest extends Request



	# a reference to the HTTP response handle
	_http: null



	constructor: (input, http) ->
		super input

		@_http = http



	respond: (output) =>
		@_http.statusCode = 200
		@_http.end JSON.stringify
			status: 'ok'
			message: output


	error: (error) =>
		@_http.statusCode = 500
		@_http.end JSON.stringify
			status: 'error'
			message: error





class HTTPAdapter extends Adapter



	# adapter name
	name: 'http'

	# HTTP server
	server: null



	constructor: (bot) ->
		super bot

		# setup HTTP server
		@server = http.createServer()

		@server.on 'close', () ->
			process.exit 0

		@server.on 'request', (request, response) =>
			response.setHeader 'Content-Type', 'application/json'
			input = ''
			request.on 'data', (data) ->
				input += data
			request.once 'end', () =>
				@emit 'request', new HTTPRequest input, response

		@server.listen 8000





module.exports = HTTPAdapter