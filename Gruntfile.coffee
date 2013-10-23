
sysPath = require 'path'

module.exports = (grunt) ->
  grunt.initConfig(
    coffee:
      main:
        expand: true
        src: ['scripts/**/*.coffee']
        dest: 'public/'
        ext: '.js'

    less:
      main:
        expand: true
        src: ['styles/**/*.less']
        dest: 'public/'
        ext: '.css'
        filter: (filepath) ->
          return true if grunt.file.isDir filepath
          not grunt.util._(sysPath.basename filepath).startsWith '_'

    jade:
      main:
        options:
          data: (dest, src) ->
            src = src[0]
            modulePath = src.replace sysPath.extname(src), ''
            jsModuleExist = grunt.file.exists modulePath + '.js'
            jsonModuleExist = grunt.file.exists modulePath + '.json'
            coffeeModuleExist = grunt.file.exists modulePath + '.coffee'
            return {} unless jsModuleExist or jsonModuleExist or coffeeModuleExist
            require './' + modulePath
        expand: true
        cwd: 'pages'
        src: ['**/*.jade']
        dest: 'public/'
        ext: '.html'
        filter: (filepath) ->
          return true if grunt.file.isDir filepath
          not grunt.util._(sysPath.basename filepath).startsWith '_'

    concat:
      options: separator: ';'
      vendor:
        dest: 'public/scripts/vendor.js'
        src: [
          'bower_components/jquery/jquery.js'
          'bower_components/bootstrap/js/transition.js'
        ]

    copy:
      vendor:
        expand: true
        src: [
        ]
        dest: 'public/scripts/'
      assets:
        expand: true
        cwd: 'assets/'
        src: '**/*'
        dest: 'public/'

    watch:
      options: livereload: true
      scripts:
        files: 'scripts/**/*'
        tasks: ['coffee']
      styles:
        files: 'styles/**/*'
        tasks: ['less']
      pages:
        files: 'pages/**/*'
        tasks: ['jade']
      assets:
        files: 'assets/**/*'
        tasks: ['copy']
  )

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-less'
  grunt.loadNpmTasks 'grunt-contrib-jade'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-cssmin'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-imagemin'
  grunt.loadNpmTasks 'grunt-contrib-connect'

  grunt.registerTask 'build', ['coffee', 'less', 'jade', 'copy', 'concat']
  grunt.registerTask 'default', ['build', 'watch']
