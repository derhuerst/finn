#!/usr/bin/env coffee

# geoffrey
# goeffrey is a Siri-like personal assistant running on node.js.
# v0.2.0





# dependencies
minimist 	= require 'minimist'
path 			= require 'path'
fs 			= require 'fs'
log			= require 'obs-log'
Geoffrey	= require './index'





pkg			= require './package.json'
switches = [
	'-w	wit.ai token (required)'
	'-s	scripts path'
	'-p	port'
	'-h	this help'
	'-v	geoffrey version'
]
options = minimist process.argv





# option -h
if options.h?
	console.log switches.join '\n'
	process.exit 0

# option -v
if options.v?
	console.log pkg.version
	process.exit 0

# option -w
if not options.w?
	console.log 'no wit.ai token passed'
	process.exit 1

# option -p
if not options.p?
	options.p = 10000

# option -s
isDir = (path) ->
	return fs.existsSync(options.s) and fs.statSync(options.s).isDirectory()
if not options.s?
	options.s = path.resolve process.env.HOME, '.geoffrey'
	if not isDir options.s
		fs.mkdirSync options.s, 0o755
else
	if not isDir options.s
		console.log 'script directory doesn\'t exist'
		process.exit 1

# run the server
server = new Geoffrey
	witToken: options.w
	scripts: options.s
	port: options.p