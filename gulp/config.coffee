config =
  bootstrap: './src/bootstrap.coffee'
  outputName: 'vigorjs.componentmanager.js'
  outputNameMinified: 'vigorjs.componentmanager.min.js'
  serverTarget: './examples'
  specFiles: ['test/**/*.coffee']
  dest: './dist'
  publicDest: './public/js'
  exampleAppDest: './public/examples/example-app/lib/'
  src: './src/'
  fileTypes: ['.js', '.css', '.txt', '.ico', '.html', '.png']
  debug: false

module.exports = config