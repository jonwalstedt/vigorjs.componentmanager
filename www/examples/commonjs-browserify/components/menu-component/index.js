var Menu,
    MenuView = require('./MenuView'),
    MenuItemCollection = require('./MenuItemCollection');

Menu = function (args) {
  console.log('Menu initialized, args: ', args);
  this._menuItems = new MenuItemCollection([
    {
      id: 'item-1',
      label: 'Menu Item 1',
      href: '#1'
    },
    {
      id: 'item-2',
      label: 'Menu Item 2',
      href: '#2'
    },
    {
      id: 'item-3',
      label: 'Menu Item 3',
      href: '#3'
    }
  ]);
  this._menuView = new MenuView({collection: this._menuItems});
  this.$el = this._menuView.$el;
};

Menu.prototype.render = function () {
  this._menuView.render();
  return this;
},

Menu.prototype.dispose = function () {
  this._menuView.dispose();
  return this;
}

module.exports = Menu;
