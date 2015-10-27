var app = app || {};

(function ($) {
  'use strict';

  app.Router = Backbone.Router.extend({

    previousRoute: undefined,

    routes: {
      '*action': '_onAllRoutes',
      '*notFound': '_onAllRoutes'
    },

    _onAllRoutes: function () {
      this.triggerCustomRouteInfo();
    },

    triggerCustomRouteInfo: function (route) {
      var route = Backbone.history.fragment,
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

      this.trigger('route-change', routeInfo);
      this.previousRoute = route;
    }

  });

})(jQuery);
