var app = app || {};

(function ($) {
  'use strict';

  app.Router = Backbone.Router.extend({

    routes: {
      "": "home",
      "include-if-string-matches": "includeIfStringMatches",
      "has-to-match-string": "hasToMatchString",
      "cant-match-string": "cantMatchString"
    },

    home: function () {
      console.log('home');
      Vigor.componentManager.refresh();
    },

    includeIfStringMatches: function () {
      console.log('includeIfStringMatches');
      var filterOptions = {
        route: Backbone.history.fragment,
        includeIfStringMatches: 'test'
      };
      Vigor.componentManager.refresh(filterOptions);
    },

    hasToMatchString: function () {
      console.log('hasToMatchString');
      var filterOptions = {
        route: Backbone.history.fragment,
        hasToMatchString: 'test'
      };
      Vigor.componentManager.refresh(filterOptions);
    },

    cantMatchString: function () {
      console.log('cantMatchString');
      var filterOptions = {
        route: Backbone.history.fragment,
        cantMatchString: 'test'
      };
      Vigor.componentManager.refresh(filterOptions);
    }
  });

})(jQuery);
