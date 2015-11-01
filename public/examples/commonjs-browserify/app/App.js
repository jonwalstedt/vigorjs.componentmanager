var App = function () {},
    Backbone = require('backbone'),
    Vigor = require('vigorjs.componentmanager'),
    Router = require('./Router'),
    componentSettings = require('./componentSettings'),
    MainLayoutView = require('./MainLayoutView');

App.prototype.initialize = function () {
  this.mainLayout = new MainLayoutView({
    el: '.app-wrapper'
  });

  Vigor.componentManager.initialize({
    componentSettings: componentSettings,
    context: this.mainLayout.$el
  });

  this.router = new Router();
  Backbone.history.start({root: '/examples/commonjs-browserify/'});
}

module.exports = App;