var MenuItemModel,
    Backbone = require('backbone');

MenuItemModel = Backbone.Model.extend({
  defaults: {
    id: undefined,
    label: undefined,
    href: undefined
  }
});

module.exports = MenuItemModel;
