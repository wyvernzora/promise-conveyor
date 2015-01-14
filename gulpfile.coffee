gulp = require 'gulp'
coffee = require 'gulp-coffee'

gulp.task 'default', ->

  gulp.src ['src/*.coffee'], base: 'src'
    .pipe coffee()
    .pipe gulp.dest('./dist')
