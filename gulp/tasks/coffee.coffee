gulp = require 'gulp'
coffee = require 'gulp-coffee'
include = require 'gulp-include'
rename = require 'gulp-rename'
stripCode = require 'gulp-strip-code'
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
  do buildLib

gulp.task 'coffee-test', ->
  do buildTestLib

buildLib = ->
  gulp.src(config.bootstrap)
    .pipe include()
    .pipe coffee()
    .on('error', handleError)
    .pipe rename(config.outputName)
    .pipe stripCode({
      start_comment: 'start-test-block',
      end_comment: 'end-test-block'
    })
    .pipe header(banner, pkg: pkg)
    .pipe gulp.dest(config.dest)
    .pipe gulp.dest(config.publicDest)

buildTestLib = ->
  gulp.src(config.bootstrap)
    .pipe include()
    .pipe coffee()
    .on('error', handleError)
    .pipe rename(config.outputName)
    .pipe header(banner, pkg: pkg)
    .pipe gulp.dest(config.dest)
    .pipe gulp.dest(config.publicDest)

handleError = (error) ->
  console.log error
  this.emit 'end'
