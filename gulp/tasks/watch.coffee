config = require '../config'
gulp = require 'gulp'

gulp.task 'watch', ['coffee', 'server'], ->
  gulp.watch ["#{config.src}/**/*.coffee"], ['coffee']
