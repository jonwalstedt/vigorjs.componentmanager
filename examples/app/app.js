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
    template: _.template($('script.main-template').html()),

    events: {
      'click .add-component': '_onAddComponentBtnClick'
    },

    initialize: function () {
      Vigor.componentManager.initialize({componentSettings: window.componentSettings});
      this.router = new AppRouter();
      this.router.on('route', function () {
        var filterOptions = {
          route: Backbone.history.fragment
        };

        Vigor.componentManager.refresh(filterOptions);
      });
      Backbone.history.start({root: '/examples/'});
    },

    render: function () {
      this.$el.html(this.template());
    },

    _onAddComponentBtnClick: function () {
      var component = window.componentSettings.targets.main[0];

      console.log('im clicked', component);
    }
  });

})(jQuery);
