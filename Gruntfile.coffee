module.exports = (grunt) ->
  require('matchdep').filterDev('grunt-*').forEach grunt.loadNpmTasks

  grunt.initConfig
    tusk_coffee:
      vendor:
        options:
          wrap: null
          runtime: false
        files:
          'public/javascripts/vendor.js': [
            'vendor/javascripts/chance.js'
            'vendor/javascripts/common.js'
            'vendor/javascripts/EventBus.js'
            'vendor/javascripts/underscore.js'
            'vendor/javascripts/jquery.js'
            'vendor/javascripts/rng.js'
            'vendor/javascripts/easel.js'
            'vendor/javascripts/tween.js'
            'vendor/javascripts/rot.js'
          ]
      app:
        options:
          wrap: 'CommonJS'
          modulesRoot: 'app'
          runtime: false
        files:
          'public/javascripts/app.js': ['app/**/*.coffee']

    watch:
      options:
        nospawn: true
      main:
        files: [
          'app/assets/**/*.html'
          'app/assets/**/*.css'
          'app/**/*.coffee'
        ]
        tasks: ['build']

    clean:
      build: [
        'public'
      ]

    copy:
      main:
        files: [
          {expand: true, cwd: 'app/assets/', src: ['**'], dest: 'public'}
        ]

    uglify:
      deploy:
        files:
          'public/javascripts/app.js': ['public/javascripts/app.js']
          'public/javascripts/vendor.js': ['public/javascripts/vendor.js']

  grunt.registerTask 'live', ['build', 'watch']
  grunt.registerTask 'build', ['clean:build', 'tusk_coffee', 'copy:main']
  grunt.registerTask 'deploy', ['build', 'uglify']
