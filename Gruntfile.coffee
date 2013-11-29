
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
          pretty: true
          data: (dest, [src]) ->
            modulePath = src.replace sysPath.extname(src), ''

            jsModuleExist = grunt.file.exists modulePath + '.js'
            jsonModuleExist = grunt.file.exists modulePath + '.json'
            coffeeModuleExist = grunt.file.exists modulePath + '.coffee'

            if jsModuleExist or jsonModuleExist or coffeeModuleExist
              data = require './' + modulePath
            else
              data = {}

            [
              file: 'partials/_header'
              dataname: 'header'
            ,
              file: 'partials/_footer'
              dataname: 'footer'
            ].forEach ({file, dataname}) ->
              path = './' + sysPath.join sysPath.dirname(src), 'partials/_header'
              data[dataname] = require path

            data

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
          'bower_components/bootstrap/js/dropdown.js'
          'bower_components/templayed.js/src/templayed.js'
          'bower_components/spin.js/dist/spin.js'
        ]

    copy:
      vendor:
        expand: true
        cwd: 'bower_components/'
        src: [
          'momentjs/moment.js'
          'momentjs/lang/zh-cn.js'
          'jquery.scrollTo/jquery.scrollTo.js'
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

