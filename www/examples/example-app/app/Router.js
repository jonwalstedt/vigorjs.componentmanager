define(function (require) {
  'use strict';

  var Router,
      EventBus = require('vigor').EventBus,
      EventKeys = require('EventKeys'),
      Backbone = require('backbone');

  Router = Backbone.Router.extend({

    previousRoute: undefined,

    routes: {
      '*action': '_triggerCustomRouteInfo',
      '*notFound': '_triggerCustomRouteInfo'
    },

    // This method will catch all routes
    _triggerCustomRouteInfo: function (route) {
      var route = Backbone.history.fragment,
          currentDepth = route.split('/').length - 1,
          previousDepth = this.previousRoute == undefined ? 0 : this.previousRoute.split('/').length - 1,
          index = currentDepth - previousDepth,
          routeInfo;

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
