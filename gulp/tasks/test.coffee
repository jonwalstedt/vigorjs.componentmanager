gulp = require 'gulp'
istanbul = require 'gulp-istanbul'
mocha = require 'gulp-mocha'
config  = require '../config'

jsdom = require 'jsdom'
jsdom.defaultDocumentFeatures =
  ProcessExternalResources: true
  ProcessExternalResources : ['script', 'frame', 'iframe']
  FetchExternalResources : ['script','img','css','frame','iframe','link']
  MutationEvents: true
  QuerySelector : true

global.document = jsdom.jsdom()
global.window = document.defaultView
global.$ = require "jquery"
global._ = require 'underscore'
global.Backbone = require 'backbone'
global.Backbone.$ = global.$

distFile = ["#{config.dest}/#{config.outputName}"]

gulp.task 'pre-test', ['coffee-test'], ->
  gulp.src distFile
    .pipe istanbul()
    .pipe istanbul.hookRequire()

gulp.task 'test', ['pre-test'], ->
  gulp.src config.specFiles
    .pipe mocha reporter: 'spec'
    .pipe istanbul.writeReports dir: './public/coverage'
    .pipe istanbul.enforceThresholds thresholds: { global: 90 }
    .on 'finish', ->
      gulp.start 'coffee'

gulp.task 'test-no-coverage', ->
  gulp.src config.specFiles
    .pipe mocha reporter: 'spec'
