define(function (require) {

  'use strict';

  var Chart,
      $ = require('jquery'),
      ComponentBase = require('components/ComponentBase'),
      LineChartView = require('./line-chart/LineChartView'),
      LineChartViewModel = require('./line-chart/LineChartViewModel'),
      BarChartView = require('./bar-chart/BarChartView'),
      BarChartViewModel = require('./bar-chart/BarChartViewModel'),
      DoughnutChartView = require('./doughnut-chart/DoughnutChartView'),
      DoughnutChartViewModel = require('./doughnut-chart/DoughnutChartViewModel');

  Chart = ComponentBase.extend({
    LINE_CHART: 'line-chart',
    BAR_CHART: 'bar-chart',
    DOUGHNUT_CHART: 'doughnut-chart',

    $el: undefined,
    _chartViewModel: undefined,
    _chartView: undefined,

    constructor: function (options) {
      // console.log('Chart initialized');
      var ChartView, ChartViewModel;
      this.type = options.type || this.LINE_CHART;

      ChartView = this._getChartView(this.type);
      ChartViewModel = this._getChartViewModel(this.type);

      this._chartViewModel = new ChartViewModel(options);

      this._chartView = new ChartView({
        viewModel: this._chartViewModel
      });

      this.$el = this._chartView.$el;
      $.when(this._chartView.getRenderDonePromise()).then(_.bind(this._resolvePromise, this));
      ComponentBase.prototype.constructor.apply(this, arguments);
    },

    render: function () {
      this._chartView.render();
      return this;
    },

    dispose: function () {
      console.log('chart disposed');
      this._chartView.dispose();
      this._chartViewModel.dispose();
      this._chartView = undefined;
      this._chartViewModel = undefined;
      this.$el.remove();
      this.$el = undefined;
    },

    onPageReady: function () {
      console.log('chart onPageReady - creating chart');
      this._chartView.createChart();
    },

    _getChartView: function (type) {
      var chartView;
      switch (type) {
        case this.LINE_CHART:
          chartView = LineChartView;
          break;
        case this.BAR_CHART:
          chartView = BarChartView;
          break;
        case this.DOUGHNUT_CHART:
          chartView = DoughnutChartView;
          break;
        default:
          chartView = LineChartView;
      }
      return chartView;
    },

    _getChartViewModel: function (type) {
      var chartViewModel;
      switch (type) {
        case this.LINE_CHART:
          chartViewModel = LineChartViewModel;
          break;
        case this.BAR_CHART:
          chartViewModel = BarChartViewModel;
          break;
        case this.DOUGHNUT_CHART:
          chartViewModel = DoughnutChartViewModel;
          break;
        default:
          chartViewModel = LineChartViewModel;
      }
      return chartViewModel;
    },

    _resolvePromise: function () {
      this._renderDeferred.resolve();
    }

  });

  return Chart;

});
