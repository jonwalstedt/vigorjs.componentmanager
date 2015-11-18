define(function (require) {

  'use strict';

  var ComponentViewBase,
      $ = require('jquery'),
      ComponentView = require('vigor').ComponentView;

  ComponentViewBase = ComponentView.extend({

    _renderDeferred: undefined,

    initialize: function (options) {
      ComponentView.prototype.initialize.apply(this, arguments);
      this._renderDeferred = $.Deferred();
    },

    renderStaticContent: function () {
      return this;
    },

    renderDynamicContent: function () {
      this._renderDeferred.resolve();
      return this;
    },

    addSubscriptions: function () {
      this.viewModel.addSubscriptions();
    },

    removeSubscriptions: function () {
      this.viewModel.removeSubscriptions();
    },

    dispose: function () {
      ComponentView.prototype.dispose.apply(this, arguments);
    },

    getRenderDonePromise: function () {
      return this._renderDeferred.promise();
    }
  });

  return ComponentViewBase;

});
