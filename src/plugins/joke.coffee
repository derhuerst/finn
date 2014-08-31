# dependencies
request			= require 'request'
q				= require 'q'

Plugin			= require '../Plugin'





class JokePlugin extends Plugin



	# plugin name
	name: 'joke'


	process: (input) ->
		deferred = q.defer()
		request 'http://api.icndb.com/jokes/random?escape=javascript', (error, response, body) ->
			if error
				deferred.reject new Error 'coudn\'t connect to the jokes database'
			else
				body = JSON.parse body
				deferred.resolve body.value.joke
		return deferred.promise





module.exports = JokePlugin