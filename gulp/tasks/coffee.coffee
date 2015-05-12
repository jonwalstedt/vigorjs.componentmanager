gulp = require 'gulp'
coffee = require 'gulp-coffee'
include = require 'gulp-include'
rename = require 'gulp-rename'
stripCode = require 'gulp-strip-code'
livereload = require 'gulp-livereload'
header = require 'gulp-header'
pkg = require '../../package.json'
config = require '../config'

banner = ['/**',
  ' * <%= pkg.name %> - <%= pkg.description %>',
  ' * @version v<%= pkg.version %>',
  ' * @link <%= pkg.homepage %>',
  ' * @license <%= pkg.license %>',
  ' */',
  ''].join('\n');

gulp.task 'coffee', ->
  buildLib config.bootstrap, config.outputName, config.dest
  buildLib config.bootstrapControls, config.controlsOutputName, config.dest

gulp.task 'coffee-test', ->
  buildTestLib config.bootstrap, config.outputName, config.dest
  buildTestLib config.bootstrapControls, config.controlsOutputName, config.dest

buildLib = (files, outputName, dest) ->
  gulp.src(files)
    .pipe include()
    .pipe coffee()
    .on('error', handleError)
    .pipe rename(outputName)
    .pipe stripCode({
      start_comment: 'start-test-block',
      end_comment: 'end-test-block'
    })
    .pipe header(banner, pkg: pkg)
    .pipe gulp.dest(dest)
    .pipe livereload()

buildTestLib = (files, outputName, dest) ->
  gulp.src(files)
    .pipe include()
    .pipe coffee()
    .on('error', handleError)
    .pipe rename(outputName)
    .pipe header(banner, pkg: pkg)
    .pipe gulp.dest(dest)
    .pipe livereload()

handleError = (error) ->
  console.log error
  this.emit 'end'
