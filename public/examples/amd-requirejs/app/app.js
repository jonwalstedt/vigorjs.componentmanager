define (function (require) {
  'use strict';

  var App = function () {},
      Backbone = require('backbone'),
      Vigor = require('vigor'),
      Router = require('./Router'),
      componentSettings = require('./componentSettings'),
      MainLayoutView = require('app/MainLayoutView'),

      // Components has to be required priror to initialization of the
      // componentManager - no lazy loading yet :(
      Menu = require('components/menu');

  App.prototype.initialize = function () {

    this.mainLayout = new MainLayoutView ({
      el: '.app-wrapper'
    });

    Vigor.componentManager.initialize({
      componentSettings: componentSettings,
      context: this.$el
    });

    this.router = new Router();
    Backbone.history.start({root: '/examples/amd-requirejs/'});
    return this;
  }

  return new App().initialize();
});