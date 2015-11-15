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
      var filter = {},
          url = Backbone.history.fragment;

      if (url !== "") {
        filter.url = url;
      }

      Vigor.componentManager.refresh(filter, function (activeInstances) {
        console.log('activeInstances: ',  activeInstances);
      });
    }

  });

})(jQuery);
