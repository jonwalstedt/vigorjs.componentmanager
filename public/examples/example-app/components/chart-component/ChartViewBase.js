var app = app || {};
app.components = app.components || {};

(function ($) {
  'use strict';
  app.components.ChartViewBase = app.components.ComponentViewBase.extend({

    className: 'chart-component',
    model: undefined,
    template: _.template($('script.chart-component-template').html()),

    chartOptions: undefined,

    initialize: function (options) {
      app.components.ComponentViewBase.prototype.initialize.apply(this, arguments);
    },

    renderStaticContent: function () {
      var templateData = {
            title: this.viewModel.getTitle()
          },
          $canvas;

      this.$el.html(this.template(templateData));
      $canvas = $('.chart-component__canvas', this.$el);
      this.ctx = $canvas.get(0).getContext('2d');

      this._renderDeferred.resolve();
      return this;
    },

    renderDynamicContent: function () {
      return this;
    },

    addSubscriptions: function () {
      this.viewModel.addSubscriptions();
    },

    removeSubscriptions: function () {
      this.viewModel.removeSubscriptions();
    },

    dispose: function () {
      app.components.ComponentViewBase.prototype.dispose.apply(this, null);
    },

    // Im a noop
    createChart: function () {}
  });
})(jQuery);