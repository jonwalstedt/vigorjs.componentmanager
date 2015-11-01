define (function (require) {
  'use strict';

  var MainLayoutView = Backbone.View.extend({
      initialize: function () {
      console.log('MainLayoutView initialized');
      }
    });

  return MainLayoutView;
});