define(function (require) {

  'use strict';

  var BarChartView,
      Backbone = require('backbone'),
      Chart = require('Chart'),
      ChartViewBase = require('../ChartViewBase');

  BarChartView = ChartViewBase.extend({

    className: 'chart-component barchart-component',

    chartOptions: {
      animation: true,
      animationSteps: 360,
      maintainAspectRatio: false,
      scaleShowGridLines : false,
      barShowStroke : false
    },

    constructor: function () {
      Backbone.View.prototype.constructor.apply(this, arguments);
    },

    createChart: function () {
      var chartData = this.viewModel.getChartData();
      this.chart = new Chart(this.ctx).Bar(chartData, this.chartOptions);
    },

    // renderStaticContent: function () {
    //   ChartViewBase.prototype.renderStaticContent.apply(this, arguments);
    // },

    // renderDynamicContent: function () {
    //   ChartViewBase.prototype.renderDynamicContent.apply(this, arguments);
    // },

    // addSubscriptions: function () {
    //   ChartViewBase.prototype.addSubscriptions.apply(this, arguments);
    // },

    // removeSubscriptions: function () {
    //   ChartViewBase.prototype.removeSubscriptions.apply(this, arguments);
    // },

    // dispose: function () {
    //   ChartViewBase.prototype.dispose.apply(this, arguments);
    // }

  });

  return BarChartView;

});