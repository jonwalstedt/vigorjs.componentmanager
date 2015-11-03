requirejs.config({
  baseUrl: './',
  paths: {
    jquery: '//ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min',
    underscore: '//cdnjs.cloudflare.com/ajax/libs/underscore.js/1.7.0/underscore-min',
    backbone: '//cdnjs.cloudflare.com/ajax/libs/backbone.js/1.1.2/backbone',
    Handlebars: '//cdnjs.cloudflare.com/ajax/libs/handlebars.js/4.0.4/handlebars',
    text: '//cdnjs.cloudflare.com/ajax/libs/require-text/2.0.12/text',
    hbars: '//cdnjs.cloudflare.com/ajax/libs/requirejs-handlebars/0.0.2/hbars',
    vigor: '/js/vigor.componentmanager',
    app: './app',
    components: './components'
  },
  packages: [
    {name: 'components/menu', location: 'components/menu-component'}
  ],
  shim: {
    Handlebars: {
      exports: 'Handlebars'
    }
  },
  deps: ['app/app']
});
