requirejs.config({
  baseUrl: './',
  paths: {
    jquery: '//ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min',
    underscore: '//cdnjs.cloudflare.com/ajax/libs/underscore.js/1.8.3/underscore-min',
    backbone: '//cdnjs.cloudflare.com/ajax/libs/backbone.js/1.1.2/backbone',
    Handlebars: '//cdnjs.cloudflare.com/ajax/libs/handlebars.js/4.0.4/handlebars',
    text: '//cdnjs.cloudflare.com/ajax/libs/require-text/2.0.12/text',
    hbars: '//cdnjs.cloudflare.com/ajax/libs/requirejs-handlebars/0.0.2/hbars',
    Chart: '//cdnjs.cloudflare.com/ajax/libs/Chart.js/1.0.2/Chart.min',
    TweenMax: '//cdnjs.cloudflare.com/ajax/libs/gsap/1.18.0/TweenMax.min',
    vigor: './lib/vigor',
    componentManager: './lib/vigorjs.componentmanager',
    app: './app',
    utils: './utils',
    components: './components',
    templates: './templates',
    services: './app-data/services',
    repositories: './app-data/repositories',
    producers: './app-data/producers',
    EventKeys: './app-data/EventKeys',
    SubscriptionKeys: './app-data/SubscriptionKeys'
  },
  packages: [
    {name: 'components/chart', location: 'components/chart-component'},
    {name: 'components/circular-chart', location: 'components/circular-chart-component'},
    {name: 'components/file-list', location: 'components/file-list-component'},
    {name: 'components/menu', location: 'components/menu-component'},
    {name: 'components/mini-profile', location: 'components/mini-profile-component'},
    {name: 'components/media-player', location: 'components/media-player-component'},
  ],
  shim: {
    Handlebars: {
      exports: 'Handlebars'
    }
  },
  deps: ['./bootstrap']
});
