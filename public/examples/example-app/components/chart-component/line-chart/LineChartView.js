define(function (require) {

  'use strict';

  var LineChartView,
      ColorUtil = require('utils/ColorUtil'),
      Backbone = require('backbone'),
      Chart = require('Chart'),
      LineChartCustom = require('./LineChartCustom'),
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
      this._tweakColors(chartData.datasets);

      this.chart = new Chart(this.ctx).LineCustom(chartData, this.chartOptions);
    },

    _tweakColors: function (datasets) {
      for (var i = 0; i < datasets.length; i++) {
        var set = datasets[i],
            linearGradient = this.ctx.createLinearGradient(0, 0, 0, this.$canvas.height()),
            colorObj = ColorUtil.sbcRip(set.fillColor),
            alpha = i == 0 ? 0.1 : 0.4,
            darkenedAlpha = i == 0 ? 0.3 : 0.9,
            lightenedAlpha = i == 0 ? 0.3 : 0.5,
            color = 'rgba(' + colorObj[0] + ', ' + colorObj[1] + ', ' + colorObj[2] + ', ' + alpha +')',
            darkenedColorObj = ColorUtil.sbcRip(ColorUtil.shadeBlendConvert(-0.4, set.fillColor)),
            lightenedColorObj = ColorUtil.sbcRip(ColorUtil.shadeBlendConvert(0.4, set.fillColor)),
            darkenedColor = 'rgba(' + darkenedColorObj[0] + ', ' + darkenedColorObj[1] + ', ' + darkenedColorObj[2] + ', ' + darkenedAlpha +')',
            lightenedColor = 'rgba(' + lightenedColorObj[0] + ', ' + lightenedColorObj[1] + ', ' + lightenedColorObj[2] + ', ' + lightenedAlpha +')';

        linearGradient.addColorStop(0, color);
        linearGradient.addColorStop(1, darkenedColor);

        set.strokeColor = lightenedColor;
        set.fillColor = linearGradient;
      };
    },

  });

  return LineChartView;

});