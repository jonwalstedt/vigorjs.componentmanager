config =
  bootstrap: './src/bootstrap.coffee'
  outputName: 'vigor.componentmanager.js'
  serverTarget: './examples'
  specFiles: ['test/**/*.coffee']
  dest: './dist'
  src: './src/'
  fileTypes: ['.js', '.css', '.txt', '.ico', '.html', '.png']
  debug: false

module.exports = config