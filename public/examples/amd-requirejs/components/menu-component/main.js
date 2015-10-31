define (function (require) {
  'use strict';
  var
    MenuView = require('./MenuView'),

    Menu = function (args) {
      console.log('args: ', args);
      this._menuView = new MenuView();
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

  return Menu;
});