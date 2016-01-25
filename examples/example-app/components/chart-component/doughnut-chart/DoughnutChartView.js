define(function (require) {

  'use strict';

  var DoughnutChartView,
      Backbone = require('backbone'),
      ColorUtil = require('utils/ColorUtil'),
      Chart = require('Chart'),
      DoughnutChartCustom = require('./DoughnutChartCustom'),
      ChartViewBase = require('../ChartViewBase');

  DoughnutChartView = ChartViewBase.extend({

    className: 'chart-component doughnutchart-component',

    chartOptions: {
      animation: true,
      animationSteps: 60,
      segmentShowStroke : true,
      percentageInnerCutout : 70, // This is 0 for Pie charts
      segmentStrokeColor: '#000',
      animationEasing : "easeOutQuart",
      animateRotate : true,
      animateScale : false,
      responsive: true
    },

    constructor: function () {
      Backbone.View.prototype.constructor.apply(this, arguments);
    },

    createChart: function () {
      var chartData = this.viewModel.getChartData();
      this.tweakColors(chartData);
      this.chart = new Chart(this.ctx).DoughnutCustom(chartData, this.chartOptions);
    },

    tweakColors: function (data, dimFirst) {
      for (var i = 0; i < data.length; i++) {
        var set = data[i],
            linearGradient = this.ctx.createLinearGradient(0, 0, 0, this.$canvas.height()),
            darkenedAlpha = i == 0 && dimFirst ? 0.3 : 0.9,
            lightenedAlpha = i == 0 && dimFirst ? 0.3 : 0.9,
            darkenedColorObj = ColorUtil.sbcRip(ColorUtil.shadeBlendConvert(-0.4, set.color)),
            lightenedColorObj = ColorUtil.sbcRip(ColorUtil.shadeBlendConvert(0.4, set.color)),
            darkenedColor = 'rgba(' + darkenedColorObj[0] + ', ' + darkenedColorObj[1] + ', ' + darkenedColorObj[2] + ', ' + darkenedAlpha +')',
            lightenedColor = 'rgba(' + lightenedColorObj[0] + ', ' + lightenedColorObj[1] + ', ' + lightenedColorObj[2] + ', ' + lightenedAlpha +')';

        linearGradient.addColorStop(0, lightenedColor);
        linearGradient.addColorStop(1, darkenedColor);

        set.color = linearGradient;
      };
    }

  });

  return DoughnutChartView;

});