# dependencies
logme			= require 'logme'
path			= require 'path'
finn			= require '../src/index'





module.exports = (options) ->
	log = new logme.Logme
		theme: 'socket.io'
	bot = new finn.Bot
		wit: options.wit
		log: log
	bot.addAdapter path.join options.adapters, options.adapter
	bot.addPlugins options.plugins