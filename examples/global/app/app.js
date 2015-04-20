(function ($) {
  'use strict';

  // Instatiate controlls - not a part of the example app
  var controls = new ControlsView(),
      isAuthenticated = (window.localStorage.getItem('isAuthenticated') === 'true') || false;

  $('body').prepend(controls.render().$el);

  // fake loggedin status
  window.localStorage.setItem('isAuthenticated', isAuthenticated);

  app.HelloWorld = Backbone.View.extend({
    router: undefined,
    startTime: 1,
    endTime: 19,

    initialize: function () {
      console.log('app:initialize');

      Vigor.componentManager.initialize({
        componentSettings: window.componentSettings,
        $context: this.$el
      });

      // Example of setting instance conditions on the fly
      // Sets the condition to only show this component between the
      // specified start and end time
      Vigor.componentManager.updateInstance('app-banner', {
        conditions: ["not-authenticated", _.bind(this.exampleCondition, this)]
      });

      this.router = new app.Router({$container: this.$el});
      Backbone.history.start({root: '/examples/global/'});
    },

    exampleCondition: function () {
      var today = new Date().getHours();
      return (today >= this.startTime && today <= this.endTime);
    }
  });

})(jQuery);
