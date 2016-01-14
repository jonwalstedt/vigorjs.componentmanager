gulp = require 'gulp'
jsonServer = require 'gulp-json-srv'
db = require '../../public/examples/example-app/mock-data/json-db.js'

# jserver = jsonServer.start
#   port: 4000
#   deferredStart: true
#   data: db()

gulp.task 'json-server', ->
  # do jserver.start

gulp.task 'watch-json-db', ['json-server'], ->
  # gulp.watch ['../../public/examples/example-app/mock-data/json-db.js'], ->
  #   do jserver.reload
