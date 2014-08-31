# dependencies
readline		= require 'readline'
colors			= require 'colors'

Adapter			= require '../Adapter'
Request			= require '../Request'





class ShellRequest extends Request



	# output handle
	_repl: null



	constructor: (input, repl) ->
		super input

		@_repl = repl



	respond: (output) =>
		@_repl.output.write "#{output.yellow}\n"


	error: (error) =>
		@_repl.output.write "#{error.red}\n"





class ShellAdapter extends Adapter



	# adapter name
	name: 'shell'

	# user input interface
	repl: null



	constructor: (bot) ->
		super bot

		# disable logging
		@bot.log.options.level = 'warn'    # supress `debug` and `info` messages

		# setup REPL
		@repl = readline.createInterface
			input: process.stdin
			output: process.stdout
			terminal: true

		@repl.on 'close', () ->
			process.exit 0

		@repl.on 'line', (input) =>
			if input is 'exit'
				process.exit 0
			@emit 'request', new ShellRequest input, @repl

		@repl.setPrompt '', 0
		@repl.prompt()





module.exports = ShellAdapter