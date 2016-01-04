define(function (require) {
  'use strict';

  var Router,
      EventBus = require('vigor').EventBus,
      EventKeys = require('EventKeys'),
      Backbone = require('backbone');

  Router = Backbone.Router.extend({

    previousRoute: undefined,

    routes: {
      '*action': '_onAllRoutes',
      '*notFound': '_onAllRoutes'
    },

    getRoute: function () {
      return Backbone.history.fragment;
    },

    _onAllRoutes: function () {
      this._triggerCustomRouteInfo();
    },

    _triggerCustomRouteInfo: function (route) {
      var route = this.getRoute(),
          currentDepth,
          previousDepth,
          index,
          routeInfo;

      if (this.previousRoute == undefined) {
        previousDepth = 0;
      } else {
        previousDepth = this.previousRoute.split('/').length - 1;
      }

      currentDepth = route.split('/').length - 1;

      if (this.previousRoute == '' && currentDepth == 0) {
        currentDepth++;
      }

      if (previousDepth == 0 && route == '') {
        previousDepth++;
      }

      index = currentDepth - previousDepth;

      routeInfo = {
        currentDepth: currentDepth,
        previousDepth: previousDepth,
        route: route,
        previousRoute: this.previousRoute,
        index: index
      }

      EventBus.send(EventKeys.ROUTE_CHANGE, routeInfo);
      this.previousRoute = route;
    }

  });

  return Router;

});
