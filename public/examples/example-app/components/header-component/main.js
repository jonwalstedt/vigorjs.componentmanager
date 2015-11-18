define(function (require) {

  'use strict';

  var Header,
      ComponentBase = require('components/ComponentBase'),
      HeaderView = require('./HeaderView');

  Header = ComponentBase.extend({

    $el: undefined,
    _headerView: undefined,

    constructor: function (options) {
      console.log('Header initialized');
      this._headerView = new HeaderView();
      this.$el = this._headerView.$el;
      $.when(this._headerView.getRenderDonePromise()).then(_.bind(this._resolvePromise, this));
      ComponentBase.prototype.constructor.call(this, arguments);
    },

    render: function () {
      this._headerView.render();
      return this;
    },

    dispose: function () {
      console.log('Header disposed');
      this._headerView.dispose();
      this._headerView = undefined;
    },

    _resolvePromise: function () {
      this._renderDeferred.resolve();
    }
  });

  return Header;

});
