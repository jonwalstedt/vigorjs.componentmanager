define (function (require) {
  'use strict';
  var
    Backbone = require('backbone'),

    MenuView = Backbone.View.extend({

      render: function () {
        this.$el.html('hej');
      },

      dispose: function () {
        console.log('im disposed');
        this.remove();
      }

    });

  return MenuView;
});