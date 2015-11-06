gulp = require 'gulp'
istanbul = require 'gulp-coffee-istanbul'
mocha = require 'gulp-mocha'
config  = require '../config'

jsdom = require 'jsdom'
global.document = jsdom.jsdom()
global.window = document.defaultView

global.$ = require "jquery"
global._ = require 'underscore'
global.Backbone = require 'backbone'
global.Backbone.$ = global.$

distFile = ["#{config.dest}/#{config.outputName}"]

gulp.task 'test', ['coffee-test'], ->
  gulp.src distFile
    .pipe istanbul({includeUntested: true}) # Covering files
    .pipe istanbul.hookRequire()
    .on 'finish', ->
      gulp.src config.specFiles
        .pipe mocha reporter: 'spec'
        .pipe istanbul.writeReports() # Creating the reports after tests run
        .on 'finish', ->
          gulp.start 'coffee'


gulp.task 'test-no-coverage', ->
  gulp.src config.specFiles
    .pipe mocha reporter: 'spec'
