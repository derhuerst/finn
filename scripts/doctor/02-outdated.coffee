# dependencies
npm				= require 'npm'
fs				= require 'fs'
path			= require 'path'
semver			= require 'semver'





module.exports = (options, success, error) ->
	npm.load {}, () ->
		json = path.join npm.prefix, 'package.json'
		fs.readFile json, (aError, local) ->
			local = JSON.parse local
			current = local.version
			npm.commands.view [local.name], true, (aError, remote) ->    # todo: take real `local.name`
				for latest of remote
					if semver.lt current, latest
						error "Your finn version is #{current.bold}, the latest being #{latest.bold}. Please run `#{'npm update'.bold}` to update him."
					else
						success 'Your finn installation is up to date.'
					break