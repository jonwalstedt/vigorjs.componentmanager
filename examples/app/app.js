var app = app || {};

AppRouter = Backbone.Router.extend({

  routes: {
    'route1/:id': '_onRouteOne',
    'route2/:id': '_onRouteTwo',
    'route3/:id': '_onRouteThree'
  },

  _onRouteOne: function () {
    console.log('_onRouteOne');
  },

  _onRouteTwo: function () {
    console.log('_onRouteTwo');
  },

  _onRouteThree: function () {
    console.log('_onRouteThree');
  }
});

(function ($) {
  'use strict';

  app.HelloWorld = Backbone.View.extend({
    router: undefined,
    initialize: function () {
      Vigor.componentManager.initialize({componentSettings: window.componentSettings});
      this.router = new AppRouter();
      this.router.on('route', function () {
        var filterOptions = {
          route: Backbone.history.fragment
        };

        Vigor.componentManager.update(filterOptions);
        // Vigor.componentManager.renderComponents(filterOptions);
      });
      Backbone.history.start({root: '/examples/'});
    },

  });

})(jQuery);
