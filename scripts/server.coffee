# dependencies
{Logme}			= require 'logme'
log = new Logme
	theme: 'socket.io'





module.exports = (options) ->
	options.log = log
	Geoffrey = require '../'
	server = new Geoffrey options