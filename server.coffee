#!/usr/bin/env coffee

# geoffrey
# goeffrey is a Siri-like personal assistant running on node.js.
# v0.2.0





# dependencies
minimist 	= require 'minimist'
log			= require 'obs-log'
Geoffrey	= require './index'





pkg			= require './package.json'
switches = [
	'-w	wit.ai token (required)'
	'-s	scripts path'
	'-h	this help'
	'-v	geoffrey version'
]
options = minimist process.argv





# option -h
if options.h?
	console.log switches.join '\n'

# option -v
else if options.v?
	console.log pkg.version

# option -w
else if not options.w?
	throw new Error 'no wit.ai token passed'

# run the server
else
	server = new Geoffrey
		witToken: options.w
		scripts: if options.s? then options.s else '~/.geoffrey'