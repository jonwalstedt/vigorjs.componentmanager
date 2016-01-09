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
      'event/*path': '_onEventRoute',
      '*action': '_onAllOtherRoutes',
      '*notFound': '_onAllOtherRoutes'
    },

    initialize: function (options) {
      this.$el = options.$container;
      this.mainView = new app.MainView();
      this.landingView = new app.LandingView();
      this.mainView.render();
      this.landingView.render();
    },

    _onLandingRoute: function () {
      this.$el.html(this.landingView.$el);
      window.localStorage.setItem('isAuthenticated', false);
      this._refreshComponents();
    },

    _onEventRoute: function (id) {
      this.$el.html(this.mainView.$el);
      this._refreshComponents();
      this._checkIsLoggedIn();
      this.mainView.showSidePanel();
    },

    _onAllOtherRoutes: function () {
      this.$el.html(this.mainView.$el);
      this._refreshComponents();
      this._checkIsLoggedIn();
      this.mainView.hideSidePanel();
    },

    _refreshComponents: function () {
      var filter = {
        url: Backbone.history.fragment
      };
      Vigor.componentManager.refresh(filter);
    },

    _checkIsLoggedIn: function () {
      if (!(window.localStorage.getItem('isAuthenticated') === 'true')) {
        Backbone.history.navigate('', {trigger: true});
      }
    }
  });

})(jQuery);
