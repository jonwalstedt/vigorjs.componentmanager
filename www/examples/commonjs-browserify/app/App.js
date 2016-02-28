var App = function () {},
    Backbone = require('backbone'),
    Vigor = require('vigorjs.componentmanager'),
    Router = require('./Router'),
    componentSettings = require('./componentSettings'),
    MainLayoutView = require('./MainLayoutView');

App.prototype.initialize = function () {
  var componentManager,
      _isGHPages = window.location.hostname.indexOf('github') > -1,
      _baseUrl = (_isGHPages ? '/vigorjs.componentmanager/examples/commonjs-browserify/' : '/examples/commonjs-browserify/');

  this.mainLayout = new MainLayoutView({
    el: '.app-wrapper'
  });

  componentManager = Vigor.componentManager.initialize({
    componentSettings: componentSettings,
    context: this.mainLayout.$el
  });

  this.router = new Router();

  Backbone.history.start({root: _baseUrl});
}

module.exports = App;