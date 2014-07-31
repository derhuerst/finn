module.exports = (options, success, error) ->
	try
		npm = require 'npm'
		success 'NPM is installed.'
	catch
		error "#{'You don\'t have NPM installed.'.bold} NPM comes bundled with new versions of node.js, so please try to install that again. See http://nodejs.org"