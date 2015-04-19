(function ($) {
  'use strict';

  // Instatiate controlls - not a part of the example app
  var controls = new ControlsView();
  $('body').prepend(controls.render().$el);

  window.isAuthenticated = false;

  app.HelloWorld = Backbone.View.extend({
    router: undefined,

    initialize: function () {
      console.log('app:initialize');

      Vigor.componentManager.initialize({
        componentSettings: window.componentSettings,
        $context: this.$el
      });

      this.router = new app.Router({$container: this.$el});

      Backbone.history.start({root: '/examples/global/'});
    }
  });

})(jQuery);
