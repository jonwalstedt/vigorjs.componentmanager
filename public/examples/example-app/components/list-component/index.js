var app = app || {};
app.components = app.components || {};

(function ($) {
  'use strict';

  app.components.List = app.components.ComponentBase.extend({
    $el: undefined,
    _listViewModel: undefined,
    _listView: undefined,

    constructor: function (options) {
      console.log('List initialized');
      this._listViewModel = new app.components.ListViewModel({subscriptionKey: options.subscriptionKey});
      this._listView = new app.components.ListView({viewModel: this._listViewModel});
      this.$el = this._listView.$el;
      $.when(this._listView.getRenderDonePromise()).then(_.bind(this._resolvePromise, this));
      app.components.ComponentBase.prototype.constructor.apply(this, arguments);
    },

    render: function () {
      this._listView.render();
      return this;
    },

    dispose: function () {
      console.log('list disposed');
      this._listView.dispose();
      this._listViewModel.dispose();
      this._listView = undefined;
      this._listViewModel = undefined;
      this.$el.remove();
      this.$el = undefined;
    },

    _resolvePromise: function () {
      this._renderDeferred.resolve();
    }

  });
})(jQuery);
