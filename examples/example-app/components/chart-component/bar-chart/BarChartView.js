define(function (require) {

  'use strict';

  var BarChartView,
      BarChartCustom = require('./BarChartCustom'),
      Backbone = require('backbone'),
      Chart = require('Chart'),
      ChartViewBase = require('../ChartViewBase');

  BarChartView = ChartViewBase.extend({

    className: 'chart-component barchart-component',

    chartOptions: {
      animation: true,
      animationSteps: 60,
      maintainAspectRatio: false,
      scaleShowGridLines : false,
      barShowStroke : true
    },

    constructor: function () {
      Backbone.View.prototype.constructor.apply(this, arguments);
    },

    createChart: function () {
      var chartData = this.viewModel.getChartData();
      this.tweakColors(chartData.datasets);
      this.chart = new Chart(this.ctx).BarCustom(chartData, this.chartOptions);
    }
  });

  return BarChartView;

});