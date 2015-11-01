define (function (require) {
  'use strict';
  var
    Backbone = require('backbone'),
    menuTemplate = require('hbars!./templates/menu-template'),
    MenuView = Backbone.View.extend({

      render: function () {
        var templateData = {
          title: 'My example component - a menu',
          items: this.collection.toJSON()
        };
        this.$el.html(menuTemplate(templateData));
      },

      dispose: function () {
        console.log('im disposed');
        this.remove();
      }

    });

  return MenuView;
});