gulp = require 'gulp'
istanbul = require 'gulp-coffee-istanbul'
mocha = require 'gulp-mocha'
config  = require '../config'

distFile = ["#{config.dest}/#{config.outputName}"]

gulp.task 'test', ['coffee-test'], ->
  gulp.src distFile
    .pipe istanbul({includeUntested: true}) # Covering files
    .pipe istanbul.hookRequire()
    .on 'finish', ->
      gulp.src config.specFiles
        .pipe mocha reporter: 'spec'
        .pipe istanbul.writeReports() # Creating the reports after tests run

gulp.task 'test-no-coverage', ->
  gulp.src config.specFiles
    .pipe mocha reporter: 'spec'
