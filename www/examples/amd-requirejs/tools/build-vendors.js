({
  baseUrl: '../',
  paths: {
    requireLib: 'lib/require',
    jquery: 'lib/jquery.min',
    underscore: 'lib/underscore.min',
    backbone: 'lib/backbone',
    Handlebars: 'lib/handlebars',
    text: 'lib/text',
    hbars: 'lib/hbars',
    vigor: '../../js/vigor.componentmanager',
  },
  // optimize: 'none',
  wrapShim: true,
  out: '../dist/vendor-built.js',
  include: [
    'requireLib',
    'jquery',
    'underscore',
    'backbone',
    'Handlebars',
    'text',
    'hbars',
    'vigor',
  ]
})