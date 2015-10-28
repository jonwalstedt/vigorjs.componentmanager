var app = app || {};
app.components = app.components || {};

(function ($) {
  'use strict';
  app.components.DoughnutChartView = app.components.ChartViewBase.extend({

    className: 'chart-component doughnutchart-component',
    chartOptions: {
      animation: true,
      animationSteps: 300,
      segmentShowStroke : false,
      percentageInnerCutout : 90, // This is 0 for Pie charts
      animationEasing : "easeOutQuart",
      animateRotate : true,
      animateScale : false,
      responsive: true
    },

    createChart: function () {
      var chartData = this.viewModel.getChartData();
      this.chart = new Chart(this.ctx).Doughnut(chartData, this.chartOptions);
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