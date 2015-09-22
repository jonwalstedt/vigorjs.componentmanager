var app = app || {};

(function ($) {
  'use strict';

  app.Router = Backbone.Router.extend({

    routes: {
      "": "home",
      "include-if-string-matches": "includeIfStringMatches",
      "has-to-match-string": "hasToMatchString",
      "cant-match-string": "cantMatchString",
      "filter-string-has-to-match": "filterStringHasToMatch",
      "filter-string-cant-match": "filterStringCantMatch",
    },

    home: function () {
      console.log('home');
      Vigor.componentManager.refresh();
    },

    includeIfStringMatches: function () {
      console.log('includeIfStringMatches');
      var filter = {
        includeIfStringMatches: 'test'
      };
      Vigor.componentManager.refresh(filter);
    },

    hasToMatchString: function () {
      console.log('hasToMatchString');
      var filter = {
        hasToMatchString: 'test'
      };
      Vigor.componentManager.refresh(filter);
    },

    cantMatchString: function () {
      console.log('cantMatchString');
      var filter = {
        cantMatchString: 'test'
      };
      Vigor.componentManager.refresh(filter);
    },

    filterStringHasToMatch: function () {
      console.log('filterStringHasToMatch');
      var filter = {
        filterString: 'test1'
      };
      Vigor.componentManager.refresh(filter);
    },

    filterStringCantMatch: function () {
      console.log('filterStringCantMatch');
      var filter = {
        filterString: 'test2'
      };
      Vigor.componentManager.refresh(filter);
    }
  });

})(jQuery);
