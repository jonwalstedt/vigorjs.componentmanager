define (function (require) {
  'use strict';
  var
    Backbone = require('backbone'),
    MenuItemModel = require('./MenuItemModel'),

    MenuItemCollection = Backbone.Collection.extend({
      model: MenuItemModel
    });

  return MenuItemCollection;
});