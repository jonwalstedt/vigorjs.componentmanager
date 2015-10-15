var app = app || {};

(function ($) {
  'use strict';

  var FilterModel = Backbone.Model.extend({
    defaults: {
      preload: true
    }
  });

  app.filterModel = new FilterModel();

})(jQuery);
