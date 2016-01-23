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
      responsive: true,
      legendTemplate : "<ul class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=0; i<datasets.length; i++){%><li><span style=\"background-color:<%=datasets[i].strokeColor%>\"></span><%if(datasets[i].label){%><%=datasets[i].label%><%}%></li><%}%></ul>"
    },

    constructor: function () {
      Backbone.View.prototype.constructor.apply(this, arguments);
    },

    initialize: function () {
      ChartViewBase.prototype.initialize.apply(this, arguments);
      this.listenTo(this.viewModel, 'data-changed', _.bind(this._onDataChange, this));
    },

    createChart: function () {
      var chartData = this.viewModel.getChartData(),
          dimFirst = true,
          legend;

      this.tweakColors(chartData.datasets, dimFirst);
      this.chart = new Chart(this.ctx).LineCustom(chartData, this.chartOptions);
      legend = this.chart.generateLegend();
      this.$el.append(legend);
    },

    updateChart: function () {
      var chartData = this.viewModel.getChartData(),
          dimFirst = true;

      if (this.chart) {
        this.tweakColors(chartData.datasets, dimFirst);
        for (var i = 0; i < this.chart.datasets.length; i++) {
          var dataset = this.chart.datasets[i];
          for (var j = 0; j < dataset.points.length; j++) {
            var point = dataset.points[j];
            point.value = chartData.datasets[i].data[j];
          };
        };
        this.chart.update();
      }
    },

    _onDataChange: function () {
      this.updateChart();
    }
  });

  return LineChartView;

});