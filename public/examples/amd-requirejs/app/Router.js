define (function (require) {
  'use strict';
  var
    Backbone = require('backbone'),
    Vigor = require('vigor'),
    Router = Backbone.Router.extend({
      routes: {
        '*action': '_onAllRoutes',
        '*notFound': '_onAllRoutes'
      },

      _onAllRoutes: function () {
        var filter = {
          url: Backbone.history.fragment
        };
        Vigor.componentManager.refresh(filter);
      }
  });
  return Router;
});