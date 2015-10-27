var app = app || {};
app.components = app.components || {};

(function ($) {
  'use strict';

  app.components.Chart = app.components.ComponentBase.extend({
    LINE_CHART: 'line-chart',
    BAR_CHART: 'bar-chart',
    DOUGHNUT_CHART: 'doughnut-chart',

    $el: undefined,
    _chartViewModel: undefined,
    _chartView: undefined,

    // TODO: make this into a generic chart component
    constructor: function (options) {
      console.log('Chart initialized');
      var ChartView, ChartViewModel;
      this.type = options.type || this.LINE_CHART;

      ChartView = this._getChartView(this.type);
      ChartViewModel = this._getChartViewModel(this.type);

      this._chartViewModel = new ChartViewModel({
        subscriptionKey: options.subscriptionKey
      });

      this._chartView = new ChartView({
        viewModel: this._chartViewModel
      });

      this.$el = this._chartView.$el;
      $.when(this._chartView.getRenderDonePromise()).then(_.bind(this._resolvePromise, this));
      app.components.ComponentBase.prototype.constructor.apply(this, arguments);
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
      console.log('onPageReady ');
      this._chartView.createChart();
    },

    _getChartView: function (type) {
      var chartView;
      switch (type) {
        case this.LINE_CHART:
          chartView = app.components.LineChartView;
          break;
        case this.BAR_CHART:
          chartView = app.components.BarChartView;
          break;
        case this.DOUGHNUT_CHART:
          chartView = app.components.DoughnutChartView;
          break;
        default:
          chartView = app.components.LineChartView;
      }
      return chartView;
    },

    _getChartViewModel: function (type) {
      var chartViewModel;
      switch (type) {
        case this.LINE_CHART:
          chartViewModel = app.components.LineChartViewModel;
          break;
        case this.BAR_CHART:
          chartViewModel = app.components.BarChartViewModel;
          break;
        case this.DOUGHNUT_CHART:
          chartViewModel = app.components.DoughnutChartViewModel;
          break;
        default:
          chartViewModel = app.components.LineChartViewModel;
      }
      return chartViewModel;
    },

    _resolvePromise: function () {
      this._renderDeferred.resolve();
    }

  });
})(jQuery);
