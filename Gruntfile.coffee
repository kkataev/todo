# Build configurations
module.exports = (grunt) ->
	require('time-grunt')(grunt)

	grunt.initConfig
		bower:
			install:
				options:
					copy: false
			uninstall:
				options:
					cleanBowerDir: true
					copy: false
					install: false

		# Deletes dist and .temp directories
		# The .temp directory is used during the build process
		# The dist directory contains the artifacts of the build
		# These directories should be deleted before subsequent builds
		# These directories are not committed to source control
		clean:
			working: [
				'./.temp/'
				'./dist/'
			]
			# Used for those that desire plain old JavaScript
			jslove: [
				'**/*.coffee'
				'!**/bower_components/**'
				'!**/node_modules/**'
			]

		# Compiles CoffeeScript (.coffee) files to JavaScript (.js)
		coffee:
			app:
				cwd: './.temp/'
				src: '**/*.coffee'
				dest: './.temp/'
				expand: true
				ext: '.js'
				options:
					sourceMap: true
			# Used for those that desire plain old JavaScript
			jslove:
				files: [
					cwd: './'
					src: [
						'**/*.coffee'
						'!**/bower_components/**'
						'!**/node_modules/**'
					]
					dest: './'
					expand: true
					ext: '.js'
				]

		# Lints CoffeeScript files
		coffeelint:
			files: './src/scripts/**/*.coffee'
			options:
				indentation:
					value: 1
				max_line_length:
					level: 'ignore'
				no_tabs:
					level: 'ignore'

		# Sets up a web server
		connect:
			app:
				options:
					base: './dist/'
					livereload: true
					middleware: require './middleware'
					open: true
					port: 0

		# Copies directories and files from one location to another
		copy:
			app:
				files: [
					cwd: './src/'
					src: '**'
					dest: './.temp/'
					expand: true
				,
					cwd: './bower_components/angular/'
					src: 'angular.*'
					dest: './.temp/scripts/libs/'
					expand: true
				,
					cwd: './bower_components/angular-route/'
					src: 'angular-route.*'
					dest: './.temp/scripts/libs/'
					expand: true
				,
					cwd: './bower_components/angular-resource/'
					src: 'angular-resource.js'
					dest: './.temp/scripts/libs/'
					expand: true
				,
					cwd: './bower_components/bootstrap/less/'
					src: '*.less'
					dest: './.temp/styles/'
					expand: true
				,
					cwd: './bower_components/ui-slider/src'
					src: 'slider.js'
					dest: './.temp/scripts/libs/'
					expand: true
				,
					cwd: './bower_components/jquery/'
					src: '*.js'
					dest: './.temp/scripts/libs/'
					expand: true
				,
					cwd: './bower_components/bootstrap-bower/'
					src: 'ui-bootstrap-tpls.js'
					dest: './.temp/scripts/libs/'
					expand: true
				]
			dev:
				cwd: './.temp/'
				src: '**'
				dest: './dist/'
				expand: true
			prod:
				files: [
					cwd: './.temp/'
					src: 'fonts/**'
					dest: './dist/'
					expand: true
				,
					cwd: './.temp/'
					src: 'images/**'
					dest: './dist/'
					expand: true
				,
					cwd: './.temp/'
					src: [
						'scripts/ie.min.*.js'
						'scripts/scripts.min.*.js'
					]
					dest: './dist/'
					expand: true
				,
					cwd: './.temp/'
					src: 'styles/styles.min.*.css'
					dest: './dist/'
					expand: true
				,
					'./dist/index.html': './.temp/index.min.html'
				]

		# Renames files based on their hashed content
		# When the files contents change, the hash value changes
		# Used as a cache buster, ensuring browsers load the correct static resources
		#
		# glyphicons-halflings.png -> glyphicons-halflings.6c8829cc6f.png
		# scripts.min.js -> scripts.min.6c355e03ee.js
		hash:
			images: './.temp/images/**/*'
			scripts:
				cwd: './.temp/scripts/'
				src: [
					'ie.min.js'
					'scripts.min.js'
				]
				expand: true
			styles: './.temp/styles/styles.min.css'

		# Compresses png files
		imagemin:
			images:
				files: [
					cwd: './.temp/'
					src: 'images/**/*.png'
					dest: './.temp/'
					expand: true
				]
				options:
					optimizationLevel: 7

		# Runs unit tests using karma
		karma:
			unit:
				options:
					browsers: [
						'PhantomJS'
					]
					captureTimeout: 5000
					colors: true
					files: [
						'./dist/scripts/libs/angular.js'
						'./dist/scripts/libs/angular-animate.js'
						'./dist/scripts/libs/angular-route.js'
						'./bower_components/angular-mocks/angular-mocks.js'
						'./dist/scripts/**/*.js'
						'./test/scripts/**/*.{coffee,js}'
					]
					frameworks: [
						'jasmine'
					]
					junitReporter:
						outputFile: './test-results.xml'
					keepalive: false
					logLevel: 'INFO'
					port: 9876
					preprocessors:
						'**/*.coffee': 'coffee'
					reporters: [
						'dots'
						'junit'
						'progress'
					]
					runnerPort: 9100
					singleRun: true

		# Compile LESS (.less) files to CSS (.css)
		less:
			app:
				files:
					'./.temp/styles/styles.css': './.temp/styles/styles.less'

		# Minifies index.html
		# Extra white space and comments will be removed
		# Content within <pre /> tags will be left unchanged
		# IE conditional comments will be left unchanged
		# Reduces file size by over 14%
		minifyHtml:
			prod:
				src: './.temp/index.html'
				ext: '.min.html'
				expand: true

		# Compiles underscore expressions
		#
		# The example below demonstrates the use of the environment configuration setting
		# In 'prod' build the hashed file of the concatenated and minified scripts is referened
		# In environments other than 'prod' the individual files are used and loaded with RequireJS
		#
		# <% if (config.environment === 'prod') { %>
		# 	<script src="<%= config.getHashedFile('./.temp/scripts/scripts.min.js', {trim: './.temp'}) %>"></script>
		# <% } else { %>
		# 	<script data-main="/scripts/main.js" src="/scripts/libs/require.js"></script>
		# <% } %>
		template:
			indexDev:
				files:
					'./.temp/index.html': './.temp/index.html'
					'./.temp/index.jade': './.temp/index.jade'
			index:
				files: '<%= template.indexDev.files %>'
				environment: 'prod'

		# Concatenates and minifies JavaScript files
		uglify:
			scripts:
				files:
					'./.temp/scripts/ie.min.js': [
						'./.temp/scripts/libs/json3.js'
						'./.temp/scripts/libs/html5shiv-printshiv.js'
					]

		# Run tasks when monitored files change
		watch:
			basic:
				files: [
					'./src/fonts/**'
					'./src/images/**'
					'./src/scripts/**/*.js'
					'./src/styles/**/*.css'
					'./src/views/**/*.html'
				]
				tasks: [
					'copy:app'
					'copy:dev'
					#'karma'
				]
				options:
					livereload: true
					nospawn: true
			coffee:
				files: './src/scripts/**/*.coffee'
				tasks: [
					'coffeelint'
					'copy:app'
					'coffee:app'
					'copy:dev'
					#'karma'
				]
				options:
					livereload: true
					nospawn: true
			jade:
				files: './src/views/**/*.jade'
				tasks: [
					'copy:app'
					'jade:views'
					'copy:dev'
					#'karma'
				]
				options:
					livereload: true
					nospawn: true
			less:
				files: './src/styles/**/*.less'
				tasks: [
					'copy:app'
					'less'
					'copy:dev'
				]
				options:
					livereload: true
					nospawn: true
			spaHtml:
				files: './src/index.html'
				tasks: [
					'copy:app'
					'template:indexDev'
					'copy:dev'
					#'karma'
				]
				options:
					livereload: true
					nospawn: true
			spaJade:
				files: './src/index.jade'
				tasks: [
					'copy:app'
					'template:indexDev'
					'jade:spa'
					'copy:dev'
					#'karma'
				]
				options:
					livereload: true
					nospawn: true
			test:
				files: './test/**/*.*'
				tasks: [
					'karma'
				]
			# Used to keep the web server alive
			none:
				files: 'none'
				options:
					livereload: true

	# Register grunt tasks supplied by grunt-bower-task.
	# Referenced in package.json.
	# https://github.com/yatskevich/grunt-bower-task
	grunt.loadNpmTasks 'grunt-bower-task'

	# Register grunt tasks supplied by grunt-coffeelint.
	# Referenced in package.json.
	# https://github.com/vojtajina/grunt-coffeelint
	grunt.loadNpmTasks 'grunt-coffeelint'

	# Register grunt tasks supplied by grunt-contrib-*.
	# Referenced in package.json.
	# https://github.com/gruntjs/grunt-contrib
	grunt.loadNpmTasks 'grunt-contrib-clean'
	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-contrib-connect'
	grunt.loadNpmTasks 'grunt-contrib-copy'
	grunt.loadNpmTasks 'grunt-contrib-imagemin'
	grunt.loadNpmTasks 'grunt-contrib-less'
	grunt.loadNpmTasks 'grunt-contrib-uglify'
	grunt.loadNpmTasks 'grunt-contrib-watch'

	# Register grunt tasks supplied by grunt-hustler.
	# Referenced in package.json.
	# https://github.com/CaryLandholt/grunt-hustler
	grunt.loadNpmTasks 'grunt-hustler'

	# Register grunt tasks supplied by grunt-karma.
	# Referenced in package.json.
	# https://github.com/karma-runner/grunt-karma
	grunt.loadNpmTasks 'grunt-karma'

	# Compiles the app with non-optimized build settings
	# Places the build artifacts in the dist directory
	# Enter the following command at the command line to execute this build task:
	# grunt build
	grunt.registerTask 'build', [
		'clean:working'
		'copy:app'
		'coffee:app'
		'less'
		'template:indexDev'
		'copy:dev'
	]

	# Compiles the app with non-optimized build settings
	# Places the build artifacts in the dist directory
	# Opens the app in the default browser
	# Watches for file changes, and compiles and reloads the web browser upon change
	# Enter the following command at the command line to execute this build task:
	# grunt or grunt default
	grunt.registerTask 'default', [
		'build'
		'connect'
		'watch'
	]

	# Identical to the default build task
	# Compiles the app with non-optimized build settings
	# Places the build artifacts in the dist directory
	# Opens the app in the default browser
	# Watches for file changes, and compiles and reloads the web browser upon change
	# Enter the following command at the command line to execute this build task:
	# grunt dev
	grunt.registerTask 'dev', [
		'default'
	]

	# Compiles the app with optimized build settings
	# Places the build artifacts in the dist directory
	# Enter the following command at the command line to execute this build task:
	# grunt prod
	grunt.registerTask 'prod', [
		'clean:working'
		'copy:app'
		'coffee:app'
		'imagemin'
		'hash:images'
		'less'
		'uglify'
		'hash:scripts'
		'hash:styles'
		'template:index'
		'jade:spa'
		'minifyHtml'
		'copy:prod'
	]

	# Opens the app in the default browser
	# Build artifacts must be in the dist directory via a prior grunt build, grunt, grunt dev, or grunt prod
	# Enter the following command at the command line to execute this build task:
	# grunt server
	grunt.registerTask 'server', [
		'connect'
		'watch:none'
	]

	# Compiles the app with non-optimized build settings
	# Places the build artifacts in the dist directory
	# Runs unit tests via karma
	# Enter the following command at the command line to execute this build task:
	# grunt test
	grunt.registerTask 'test', [
		'build'
		'karma'
	]

	# Compiles all CoffeeScript files in the project to JavaScript then deletes all CoffeeScript files
	# Used for those that desire plain old JavaScript
	# Enter the following command at the command line to execute this build task:
	# grunt jslove
	grunt.registerTask 'jslove', [
		'coffee:jslove'
		'clean:jslove'
	]