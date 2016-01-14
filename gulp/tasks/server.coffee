config  = require '../config'
gulp  = require 'gulp'
harp = require 'harp'
browserSync = require 'browser-sync'
reload = browserSync.reload

gulp.task 'server', ['coffee', 'json-server'], ->
  port = process.env.PORT || 7070
  harp.server '.',
    port: port
  , ->
    browserSync
      proxy: "localhost:#{port}"
      notify: false

    gulp.watch "**/*.scss", ->
      reload "**/*.css", {stream: true}

    gulp.watch ["**/*.jade", "**/*.json", "**/*.md"], ->
      reload()
