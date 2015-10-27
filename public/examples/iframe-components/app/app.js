var app = app || {};

(function ($) {
  'use strict';

  app.Filter = Backbone.View.extend({
    events: {},

    initialize: function () {
      Vigor.componentManager.initialize({
        componentSettings: window.componentSettings,
        listenForMessages: true,
        context: this.$el
      });

      Backbone.history.start({root: '/examples/iframe-component/'});
      Vigor.componentManager.refresh();
    }
});

})(jQuery);
