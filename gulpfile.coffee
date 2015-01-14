gulp = require 'gulp'
coffee = require 'gulp-coffee'

gulp.task 'default', ->

  gulp.src ['*.coffee']
    .pipe coffee()
    .pipe gulp.dest('./')
