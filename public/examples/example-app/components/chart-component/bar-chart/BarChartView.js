var app = app || {};
app.components = app.components || {};

(function ($) {
  'use strict';
  app.components.BarChartView = app.components.ChartViewBase.extend({

    className: 'chart-component barchart-component',
    chartOptions: {
      animation: true,
      animationSteps: 360,
      maintainAspectRatio: false,
      scaleShowGridLines : false,
      barShowStroke : false
    },

    createChart: function () {
      var chartData = this.viewModel.getChartData();
      this.chart = new Chart(this.ctx).Bar(chartData, this.chartOptions);
    },

    renderStaticContent: function () {
      app.components.ChartViewBase.prototype.renderStaticContent.apply(this, arguments);
    },

    renderDynamicContent: function () {
      app.components.ChartViewBase.prototype.renderDynamicContent.apply(this, arguments);
    },

    addSubscriptions: function () {
      app.components.ChartViewBase.prototype.addSubscriptions.apply(this, arguments);
    },

    removeSubscriptions: function () {
      app.components.ChartViewBase.prototype.removeSubscriptions.apply(this, arguments);
    },

    dispose: function () {
      app.components.ChartViewBase.prototype.dispose.apply(this, arguments);
    }

  });
})(jQuery);