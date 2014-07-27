// todo: reqrite


// dev dependencies
var
	path		= require('path'),
	fss			= require('fs-sync'),
	fs			= require('fs'),
	minimist	= require('minimist'),
	gulp		= require('gulp'),
	concat		= require('gulp-concat'),
	wrapper		= require('gulp-wrapper'),
	header		= require('gulp-header'),
	filesize	= require('gulp-filesize'),
	rename		= require('gulp-rename'),
	uglify		= require('gulp-uglify');


// package metadata
var
	pkg = require('./package.json'),
	name = pkg.name,
	version = pkg.version,
	author = pkg.author.name;


// building paths
var paths = {
	src: './src/',
	dist: './dist/'
};


// gulp tasks
gulp.task('build', build);
gulp.task('minify', minify);


// files
var
	modules = (minimist(process.argv).modules || 'core').split(' '),
	files = (function(){
		var i,
			files = [],
			module,
			json;
		for(var i = 0; i < modules.length; i++){
			module = path.join(paths.src, modules[i]);
			json = module + '/' + module.split('/').pop() + '.json'
			if(fss.isFile(json))
				fss.readJSON(json).forEach(function(file){
					files.push(path.join(module, file + '.js'));
				});
			else if(fss.isDir(module))
				fs.readdirSync(module).forEach(function(file){
					files.push(path.join(module, file + '.js'));
				});
			else if(fss.isFile(module + '.js'))
				files.push(module + '.js');
		}
		return files;
	})();


// build pour.js from modules in ./src
function build(){
	return gulp.src(files)
		.pipe(concat(name + '.js'))
		.pipe(wrapper({
			header: fss.read(path.join(paths.src, 'header.js')),
			footer: fss.read(path.join(paths.src, 'footer.js'))
		}))
		.pipe(header('// ' + [
			name,
			author,
			'v' + version,
			modules.join(' ')
		].join(' | ') + '\n'))
		.pipe(gulp.dest(paths.dist));
	// todo: filesize
}


// minify pour.js to pour.min.js
function minify(){
	return gulp.src(path.join(paths.dist, name + '.js'))
		.pipe(uglify())    // compress js
		.pipe(header('// ' + [
			name,
			author,
			'v' + version,
			modules.join(' ')
		].join(' | ') + '\n'))
		.pipe(rename(name + '.min.js'))
		.pipe(gulp.dest(paths.dist));
	// todo: filesize
}