var app = app || {};

(function ($) {
  'use strict';

  app.Filter = Backbone.View.extend({
    events: {},

    initialize: function () {
      Vigor.componentManager.initialize({
        componentSettings: window.componentSettings,
        listenForMessages: true,
        whitelistedOrigins: 'http://localhost:7070',
        context: this.$el
      });

      Backbone.history.start({root: '/examples/iframe-component/'});
      Vigor.componentManager.refresh();
    }
});

})(jQuery);
