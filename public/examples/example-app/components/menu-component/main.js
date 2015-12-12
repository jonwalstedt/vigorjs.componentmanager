define(function (require) {

  'use strict';

  var Menu,
      ComponentBase = require('components/ComponentBase'),
      MenuView = require('./MenuView'),
      MenuViewModel = require('./MenuViewModel');

  Menu = ComponentBase.extend({
    $el: undefined,
    _menuViewModel: undefined,
    _menuView: undefined,
    _urlParamsModel: undefined,

    constructor: function (options) {
      // console.log('Menu initialized');
      this._urlParamsModel = options.urlParamsCollection.at(0);
      this._menuViewModel = new MenuViewModel();
      this._menuView = new MenuView({
        viewModel: this._menuViewModel
      });

      this.$el = this._menuView.$el;

      $.when(this._menuView.getRenderDonePromise()).then(_.bind(this._resolvePromise, this));
      this.listenTo(this._urlParamsModel, 'change:url', _.bind(this._onUrlParamsChange, this));
      ComponentBase.prototype.constructor.apply(this, arguments);
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

  return Menu;

});
