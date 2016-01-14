requirejs.config({
  baseUrl: './',
  paths: {
    jquery: '//ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min',
    underscore: '//cdnjs.cloudflare.com/ajax/libs/underscore.js/1.7.0/underscore-min',
    backbone: '//cdnjs.cloudflare.com/ajax/libs/backbone.js/1.1.2/backbone',
    Handlebars: '//cdnjs.cloudflare.com/ajax/libs/handlebars.js/4.0.4/handlebars',
    text: '//cdnjs.cloudflare.com/ajax/libs/require-text/2.0.12/text',
    hbars: '//cdnjs.cloudflare.com/ajax/libs/requirejs-handlebars/0.0.2/hbars',
    Chart: '//cdnjs.cloudflare.com/ajax/libs/Chart.js/1.0.2/Chart.min',
    TweenMax: '//cdnjs.cloudflare.com/ajax/libs/gsap/1.18.0/TweenMax.min',
    vigor: './lib/vigor',
    componentManager: './lib/vigorjs.componentmanager',
    app: './app',
    components: './components',
    templates: './templates',
    services: './app-data/services',
    repositories: './app-data/repositories',
    producers: './app-data/producers',
    EventKeys: './app-data/EventKeys',
    SubscriptionKeys: './app-data/SubscriptionKeys'
  },
  packages: [
    {name: 'components/filter', location: 'components/filter-component'},
    {name: 'components/banner', location: 'components/banner-component'},
    {name: 'components/chart', location: 'components/chart-component'},
    {name: 'components/header', location: 'components/header-component'},
    {name: 'components/list', location: 'components/list-component'},
    {name: 'components/menu', location: 'components/menu-component'},
    {name: 'components/mini-profile', location: 'components/mini-profile-component'}
  ],
  shim: {
    Handlebars: {
      exports: 'Handlebars'
    }
  },
  deps: ['./bootstrap']
});
