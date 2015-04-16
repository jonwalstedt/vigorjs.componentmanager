var app = app || {};

(function ($) {
  'use strict';

  app.Router = Backbone.Router.extend({

    $el: undefined,
    mainView: undefined,
    landingView: undefined,

    routes: {
      '': '_onLandingRoute',
      'landing': '_onLandingRoute',
      'logout': '_onLandingRoute',
      'event/:id': '_onEventRoute',
      '*action': '_onAllOtherRoutes',
      '*notFound': '_onAllOtherRoutes'
    },

    initialize: function (options) {
      this.$el = options.$container;
      this.mainView = new app.MainView();
      this.landingView = new app.LandingView();
    },

    _onLandingRoute: function () {
      this.$el.html(this.landingView.render().$el);
      this._refreshComponents();
    },

    _onEventRoute: function (id) {
      this.$el.html(this.mainView.render().$el);
      this.mainView.showSidePanel();
      this._refreshComponents();
    },

    _onAllOtherRoutes: function () {
      this.$el.html(this.mainView.render().$el);
      this.mainView.hideSidePanel();
      this._refreshComponents();
    },

    _refreshComponents: function () {
      var filterOptions = {
        route: Backbone.history.fragment
      };
      Vigor.componentManager.refresh(filterOptions);
    }
  });

})(jQuery);
