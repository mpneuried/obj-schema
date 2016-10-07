module.exports = (grunt) ->
	# Project configuration.
	grunt.initConfig
		pkg: grunt.file.readJSON('package.json')
		watch:
			module:
				files: ["_src/**/*.coffee"]
				tasks: [ "coffee:base" ]
			
			dev:
				files: ["_src/**/*.coffee"]
				tasks: [ "coffee:base", "test" ]
			
		coffee:
			base:
				expand: true
				cwd: '_src',
				src: ["lib/*.coffee"]
				dest: ''
				ext: '.js'

		clean:
			base:
				src: [ "lib" ]

		includereplace:
			pckg:
				options:
					globals:
						version: "<%= pkg.version %>"

					prefix: "@@"
					suffix: ''

				files:
					"index.js": ["index.js"]

		
		mochacli:
			options:
				require: [ "should", "coffee-coverage/register-istanbul" ]
				reporter: "spec"
				bail: false
				timeout: 3000
				slow: 3
				compilers: "coffee:coffee-script/register"

			main:
				src: [ "_src/test/main.coffee" ]
		

	# Load npm modules
	grunt.loadNpmTasks "grunt-contrib-watch"
	grunt.loadNpmTasks "grunt-contrib-coffee"
	grunt.loadNpmTasks "grunt-contrib-clean"
	grunt.loadNpmTasks "grunt-mocha-cli"
	grunt.loadNpmTasks "grunt-include-replace"
	
	# ALIAS TASKS
	grunt.registerTask "watcher", ["build", "test", "watch:dev"]
	grunt.registerTask "default", "build"
	grunt.registerTask "clear", [ "clean:base" ]
	grunt.registerTask "test", [ "mochacli:main" ]
	
	# Shortcuts 
	grunt.registerTask "b", "build"
	grunt.registerTask "w", "watch"
	grunt.registerTask "t", "test"

	# build the project
	grunt.registerTask "build", [ "clear", "coffee:base", "includereplace" ]
	grunt.registerTask "release", [ "clear", "coffee:base", "test" ]
