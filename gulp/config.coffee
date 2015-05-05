config =
  bootstrap: './src/bootstrap.coffee'
  bootstrapControls: './src/bootstrap-controls.coffee'
  outputName: 'backbone.vigor.componentmanager.js'
  controlsOutputName: 'backbone.vigor.componentmanager-controls.js'
  serverTarget: './examples'
  specFiles: ['test/**/*.coffee']
  dest: './dist'
  src: './src/'
  fileTypes: ['.js', '.css', '.txt', '.ico', '.html', '.png']
  debug: false

module.exports = config