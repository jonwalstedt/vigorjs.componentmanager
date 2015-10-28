var app = app || {};
app.components = app.components || {};

(function ($) {
  'use strict';

  app.components.Menu = app.components.ComponentBase.extend({
    $el: undefined,
    _menuViewModel: undefined,
    _menuView: undefined,
    _urlParamsModel: undefined,

    constructor: function (options) {
      console.log('Menu initialized', options);

      this._urlParamsModel = options.urlParamsModel;
      this._menuViewModel = new app.components.MenuViewModel();
      this._menuView = new app.components.MenuView({
        viewModel: this._menuViewModel
      });

      this.$el = this._menuView.$el;

      $.when(this._menuView.getRenderDonePromise()).then(_.bind(this._resolvePromise, this));
      console.log(this.listenTo);
      this.listenTo(this._urlParamsModel, 'change:url', _.bind(this._onUrlParamsChange, this));
      app.components.ComponentBase.prototype.constructor.apply(this, arguments);
    },

    render: function () {
      this._menuView.render();
      this._setActiveLink();
      return this;
    },

    dispose: function () {
      console.log('Menu disposed');
      this._menuView.dispose();
      this._menuViewModel.dispose();
      this._menuView = undefined;
      this._menuViewModel = undefined;
    },

    _setActiveLink: function () {
      var url = '#' + this._urlParamsModel.get('url');
      this._menuView.setActiveLink(url);
    },

    _resolvePromise: function () {
      this._renderDeferred.resolve();
    },

    _onUrlParamsChange: function () {
      this._setActiveLink();
    }
  });
})(jQuery);
