(function ($) {
  'use strict';

  var isAuthenticated = (window.localStorage.getItem('isAuthenticated') === 'true') || false;

  // fake loggedin status
  window.localStorage.setItem('isAuthenticated', isAuthenticated);

  app.HelloWorld = Backbone.View.extend({
    router: undefined,
    startTime: 18,
    endTime: 22,

    initialize: function () {
      console.log('app:initialize');

      Vigor.componentManager.initialize({
        componentSettings: window.componentSettings,
        $context: this.$el
      });

      // Example of setting instance conditions on the fly
      // Sets the condition to only show this component between the
      // specified start and end time
      // Vigor.componentManager.updateInstance('app-banner', {
      //   conditions: ["authenticated", _.bind(this.exampleCondition, this)]
      // });

      this.router = new app.Router({$container: this.$el});
      Backbone.history.start({root: '/examples/global/'});
    },

    exampleCondition: function () {
      var today = new Date().getHours();
      return (today >= this.startTime && today <= this.endTime);
    }
  });

})(jQuery);
