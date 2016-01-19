define(function (require) {

  'use strict';

  var LineChartView,
      ColorUtil = require('utils/ColorUtil'),
      Backbone = require('backbone'),
      Chart = require('Chart'),
      ChartViewBase = require('../ChartViewBase');

  LineChartView = ChartViewBase.extend({

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
      bezierCurve: true,
      responsive: true
    },

    constructor: function () {
      Backbone.View.prototype.constructor.apply(this, arguments);
    },

    createChart: function () {
      var chartData = this.viewModel.getChartData();

      for (var i = 0; i < chartData.datasets.length; i++) {
        var set = chartData.datasets[i],
            linearGradient = this.ctx.createLinearGradient(0, 0, 0, this.$canvas.height()),
            colorObj = ColorUtil.sbcRip(set.fillColor),
            color = 'rgba(' + colorObj[0] + ', ' + colorObj[1] + ', ' + colorObj[2] + ', 0.4)',
            darkenedColorObj = ColorUtil.sbcRip(ColorUtil.shadeBlendConvert(-0.4, set.fillColor)),
            darkenedColor = 'rgba(' + darkenedColorObj[0] + ', ' + darkenedColorObj[1] + ', ' + darkenedColorObj[2] + ', 0.9)';

        linearGradient.addColorStop(0, color);
        linearGradient.addColorStop(1, darkenedColor);

        set.fillColor = linearGradient;
      };


      this.chart = new Chart(this.ctx).Line(chartData, this.chartOptions);
    }

  });

  return LineChartView;

});