var app = app || {};

(function ($) {
  'use strict';

  app.Router = Backbone.Router.extend({

    routes: {
      '*action': '_onAllRoutes',
      '*notFound': '_onAllRoutes'
    },

    _onAllRoutes: function () {
      var filter = {
        url: Backbone.history.fragment
      };
      Vigor.componentManager.refresh(filter);
      exampleHelpers.showMsg('When the url updates the current fragment is matched against the urlPattern in the hello-world instanceDefinition configured in the targets section in components.js');
    }

  });

})(jQuery);
