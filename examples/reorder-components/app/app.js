var app = app || {};

(function ($) {
  'use strict';

  app.Filter = Backbone.View.extend({
    router: undefined,
    events: {},

    initialize: function () {
      Vigor.componentManager.initialize({
        componentSettings: window.componentSettings,
        $context: this.$el
      });

      this.router = new app.Router();
      Backbone.history.start({root: '/examples/iframe-component/'});
    }
});

})(jQuery);
