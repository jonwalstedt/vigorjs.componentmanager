define (function (require) {
  'use strict';
  var
    Backbone = require('backbone'),

    MenuItemModel = Backbone.Model.extend({

      defaults: {
        id: undefined,
        label: undefined,
        href: undefined
      }

    });

  return MenuItemModel;
});