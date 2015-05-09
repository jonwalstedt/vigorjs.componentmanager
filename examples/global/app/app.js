(function ($) {
  'use strict';

  var isAuthenticated = (window.localStorage.getItem('isAuthenticated') === 'true') || false;

  // fake loggedin status
  window.localStorage.setItem('isAuthenticated', isAuthenticated);

  app.HelloWorld = Backbone.View.extend({
    router: undefined,
    startTime: 18,
    endTime: 21,

    initialize: function () {
      console.log('app:initialize');

      Vigor.componentManager.initialize({
        componentSettings: window.componentSettings,
        $context: this.$el
      });

      this.router = new app.Router({$container: this.$el});
      Backbone.history.start({root: '/examples/global/'});


      // Example of setting instance conditions on the fly
      // Sets the condition to only show this component between the
      // specified start and end time and when logged in
      Vigor.componentManager.updateInstance('app-banner', {
        conditions: ["authenticated", _.bind(this.exampleCondition, this)]
      });
    },

    exampleCondition: function () {
      var today = new Date().getHours(),
          allowed = (today >= this.startTime && today <= this.endTime);
      return allowed;
    }
  });

})(jQuery);
