var app = app || {};

(function ($) {
  'use strict';

  app.Router = Backbone.Router.extend({

    routes: {
      '*action': '_onAllRoutes',
      '*notFound': '_onAllRoutes'
    },

    _onAllRoutes: function () {
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
