requirejs.config({
  baseUrl: './',
  paths: {
    app: './app',
    components: './components',
    jquery: '//ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min',
    underscore: '//cdnjs.cloudflare.com/ajax/libs/underscore.js/1.7.0/underscore-min',
    backbone: 'https://cdnjs.cloudflare.com/ajax/libs/backbone.js/1.1.2/backbone',
    vigor: '/js/vigor.componentmanager'
  },
  packages: [
    {name: 'components/menu', location: 'components/menu-component'}
  ]
});

requirejs(['app/app']);
