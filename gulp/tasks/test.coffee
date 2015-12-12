gulp = require 'gulp'
istanbul = require 'gulp-coffee-istanbul'
mocha = require 'gulp-mocha'
config  = require '../config'

jsdom = require 'jsdom'
global.document = jsdom.jsdom()
global.window = document.defaultView

# Mock postMessage which is missing in jsdom
postMessage = (message, targetOrigin, transfer) ->
  event = this.document.createEvent 'messageevent'
  event._type = 'message'
  event.data = message
  @dispatchEvent event

window.postMessage = postMessage.bind window


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
        .pipe istanbul.writeReports(
          {
            dir: './public/coverage',
          }
        ) # Creating the reports after tests run
        .on 'finish', ->
          gulp.start 'coffee'


gulp.task 'test-no-coverage', ->
  gulp.src config.specFiles
    .pipe mocha reporter: 'spec'
