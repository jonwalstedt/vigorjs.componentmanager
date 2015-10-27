var app = app || {};
app.components = app.components || {};

(function ($) {
  'use strict';

  app.components.Menu = app.components.ComponentBase.extend({
    $el: undefined,
    _menuViewModel: undefined,
    _menuView: undefined,

    constructor: function (options) {
      console.log('Menu initialized');

      this._menuViewModel = new app.components.MenuViewModel();
      this._menuView = new app.components.MenuView({
        viewModel: this._menuViewModel
      });

      this.$el = this._menuView.$el;

      $.when(this._menuView.getRenderDonePromise()).then(_.bind(this._resolvePromise, this));
      app.components.ComponentBase.prototype.constructor.apply(this, arguments);
    },

    render: function () {
      this._menuView.render();
      return this;
    },

    dispose: function () {
      console.log('Menu disposed');
      this._menuView.dispose();
      this._menuViewModel.dispose();
      this._menuView = undefined;
      this._menuViewModel = undefined;
    },

    _resolvePromise: function () {
      this._renderDeferred.resolve();
    }

  });
})(jQuery);
