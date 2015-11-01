var MenuItemCollection,
    Backbone = require('backbone'),
    MenuItemModel = require('./MenuItemModel');

MenuItemCollection = Backbone.Collection.extend({
  model: MenuItemModel
});

module.exports = MenuItemCollection;
