var app = app || {};
app.components = app.components || {};

(function ($) {
  'use strict';
  app.components.LineChartView = app.components.ChartViewBase.extend({

    className: 'chart-component linechart-component',
    chartOptions: {
      animation: true,
      animationSteps: 360,
      maintainAspectRatio: false,
      scaleShowGridLines : true,
      scaleGridLineColor : "rgba(0,0,0,.9)",
      scaleGridLineWidth : 1,
      scaleShowHorizontalLines: false,
      scaleShowVerticalLines: true,
      bezierCurve: false,
      responsive: true
    },

    createChart: function () {
      var chartData = this.viewModel.getChartData();
      this.chart = new Chart(this.ctx).Line(chartData, this.chartOptions);
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