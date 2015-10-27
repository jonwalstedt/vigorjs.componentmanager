var app = app || {};
app.components = app.components || {};

(function ($) {
  'use strict';

  app.components.Header = app.components.ComponentBase.extend({
    $el: undefined,
    _headerView: undefined,

    constructor: function (options) {
      console.log('Header initialized');
      this._headerView = new app.components.HeaderView();
      this.$el = this._headerView.$el;
      $.when(this._headerView.getRenderDonePromise()).then(_.bind(this._resolvePromise, this));
      app.components.ComponentBase.prototype.constructor.call(this, arguments);
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
})(jQuery);
