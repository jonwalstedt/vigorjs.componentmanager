var app = app || {};
app.components = app.components || {};

(function ($) {
  'use strict';
  app.components.ComponentViewBase = Vigor.ComponentView.extend({

    _renderDeferred: undefined,

    initialize: function (options) {
      Vigor.ComponentView.prototype.initialize.apply(this, arguments);
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
      Vigor.ComponentView.prototype.dispose.apply(this, arguments);
    },

    getRenderDonePromise: function () {
      return this._renderDeferred.promise();
    }
  });
})(jQuery);
