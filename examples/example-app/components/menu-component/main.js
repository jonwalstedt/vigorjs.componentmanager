define(function (require) {

  'use strict';

  var Menu,
      $ = require('jquery'),
      _ = require('underscore'),
      ComponentBase = require('components/ComponentBase'),
      MenuView = require('./MenuView');

  Menu = ComponentBase.extend({
    $el: undefined,
    _menuView: undefined,
    _urlParamsModel: undefined,

    constructor: function (options) {
      // console.log('Menu initialized');
      this._urlParamsModel = options.urlParamsCollection.at(0);
      this._menuView = new MenuView();

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
      this._menuView.dispose();
      this._menuView = undefined;
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
