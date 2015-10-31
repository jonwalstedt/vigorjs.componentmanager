define (function (require) {
  'use strict';
  var
    Backbone = require('backbone'),
    Vigor = require('vigor'),
    Router = require('app/Router'),
    componentSettings = require('app/componentSettings'),

    MainLayoutView = Backbone.View.extend({
      router: undefined,

      initialize: function () {
        Vigor.componentManager.initialize({
          componentSettings: componentSettings,
          context: this.$el
        });

        this.router = new Router();
        Backbone.history.start({root: '/examples/amd-requirejs/'});
      }
    });

  return MainLayoutView;
});