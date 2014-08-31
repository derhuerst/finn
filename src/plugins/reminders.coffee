# dependencies
request			= require 'request'
q				= require 'q'

Plugin			= require '../Plugin'
Storage			= require '../Storage'





class RemindersPlugin extends Plugin



	# plugin name
	name: 'reminders'


	# all reminders
	_reminders: null


	constructor: (bot) ->
		super bot
		
		@_reminders = new Storage()


	process: (input) ->
		return 'the reminders plugin isn\'t implemented yet.'





module.exports = RemindersPlugin