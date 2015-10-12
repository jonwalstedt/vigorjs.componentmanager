var app = app || {};

(function ($) {
  'use strict';

  var FilterModel = Backbone.Model.extend({
    defaults: {}
  });

  app.filterModel = new FilterModel();

})(jQuery);
