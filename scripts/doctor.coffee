# dependencies
fs		 		= require 'fs'
path	 		= require 'path'
logme			= require 'logme'
colors			= require 'colors'
spinner			= require 'simple-spinner'





module.exports = (options) ->
	# setup log
	log = new logme.Logme
		theme: 'socket.io'

	# load test list
	tests = []
	for test in fs.readdirSync path.join __dirname, 'doctor'
		tests.push test.replace /.coffee$/, ''
	tests.sort()

	# introdution
	log.info "Hi! I am the doctor. I'm going to run several tests to check if your finn installation is healthy."

	# run next test
	i = -1
	next = () ->
		i++
		if i is tests.length
			return finish()
		test = require path.join __dirname, 'doctor', tests[i]
		log.debug "Running the test #{tests[i].bold} now."
		spinner.start 75
		try
			test options, success, error
		catch e
			error 'There is an error in the module.'
		

	# success callback
	success = (message) ->
		spinner.stop()
		log.info message.green if message?
		next()

	# error callback
	error = (message) ->
		spinner.stop()
		log.error message.red
		log.info "Please run me again if you solved the problem. I will look for further problems then."
		process.exit 1

	# success callback
	finish = () ->
		log.info "I couldn't find any problems."

	# start tests
	next()