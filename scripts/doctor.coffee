# dependencies
fs		 		= require 'fs'
path	 		= require 'path'
logme			= require 'logme'
colors			= require 'colors'





module.exports = (options) ->
	# setup log
	log = new logme.Logme
		theme: 'socket.io'

	# load test list
	tests = []
	for test in fs.readdirSync path.join __dirname, 'doctor'
		tests.push test.replace /.coffee$/, ''

	# introdution
	log.info "Hi! I am the doctor. I'm going to run the tests #{tests.join(', ').bold} to check if your geoffrey installation is healthy."

	# execute tests
	for name in tests
		test = require path.join __dirname, 'doctor', name
		result = test options
		if result.ok isnt true
			log.error "test #{name}: #{result.message}"
			log.info "Please run me again if you solved the problem. I will look for further problems then."
			process.exit 1

	# success
	log.info "I couldn't find any problems."