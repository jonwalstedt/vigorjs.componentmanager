define(function (require) {

  'use strict';

  var LineChartView,
      Backbone = require('backbone'),
      Chart = require('Chart'),
      LineChartCustom = require('./LineChartCustom'),
      ChartViewBase = require('../ChartViewBase');

  LineChartView = ChartViewBase.extend({

    className: 'chart-component linechart-component',

    chartOptions: {
      animation: true,
      animationSteps: 60,
      maintainAspectRatio: false,
      scaleShowGridLines : true,
      scaleGridLineColor : "rgba(0, 0, 0, .9)",
      scaleGridLineWidth : 1,
      scaleShowHorizontalLines: false,
      scaleShowVerticalLines: true,
      bezierCurve: true,
      responsive: true
    },

    constructor: function () {
      Backbone.View.prototype.constructor.apply(this, arguments);
    },

    createChart: function () {
      var chartData = this.viewModel.getChartData(),
          dimFirst = true;

      this.tweakColors(chartData.datasets, dimFirst);
      this.chart = new Chart(this.ctx).LineCustom(chartData, this.chartOptions);
    }
  });

  return LineChartView;

});