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
    vigor: '../../js/vigorjs.componentmanager',
    app: 'app',
    components: 'components'
  },
  packages: [
    {name: 'components/menu', location: 'components/menu-component'}
  ],
  name: 'config-build',
  // optimize: 'none',
  wrapShim: true,
  out: '../dist/main-built.js',
  include: [
    'components/menu'
  ],
  exclude: [
    'requireLib',
    'jquery',
    'underscore',
    'backbone',
    'Handlebars',
    'text',
    'hbars',
    'vigor',
  ]
});

