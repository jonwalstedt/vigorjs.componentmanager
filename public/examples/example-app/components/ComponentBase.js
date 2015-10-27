var app = app || {};
app.components = app.components || {};

(function ($) {
  'use strict';
  app.components.ComponentBase = Vigor.ComponentBase.extend({

    _renderDeferred: undefined,
    componentName: 'base-component',

    constructor: function (options) {
      this.initialize(options);
    },

    initialize: function (options) {
      // Backbone.View.prototype.initialize.call(this);
      this._renderDeferred = $.Deferred();
    },

    render: function () {
      this._renderDeferred.resolve();
      return this;
    },

    dispose: function () {
      // console.log('component disposed');
    },

    getRenderDonePromise: function () {
      return this._renderDeferred.promise();
    },

    onPageReady: function () {
      // im a noop
    }
});
})(jQuery);
