gulp = require 'gulp'
coffee = require 'gulp-coffee'
include = require 'gulp-include'
rename = require 'gulp-rename'
livereload = require 'gulp-livereload'
config = require '../config'

gulp.task 'coffee', ->
  buildLib config.bootstrap, config.outputName, config.dest
  buildLib config.bootstrapControls, config.controlsOutputName, config.dest

buildLib = (files, outputName, dest) ->
  gulp.src(files)
    .pipe include()
    .pipe coffee()
    .on('error', handleError)
    .pipe rename(outputName)
    .pipe gulp.dest(dest)
    .pipe livereload()

handleError = (error) ->
  console.log error
  this.emit 'end'
