define(function (require) {

  'use strict';

  var CircualrChart,
      $ = require('jquery'),
      ComponentBase = require('components/ComponentBase'),
      CircularChartView = require('./CircularChartView'),
      CircularChartViewModel = require('./CircularChartViewModel'),

  CircualrChart = ComponentBase.extend({

    $el: undefined,
    _chartViewModel: undefined,
    _chartView: undefined,

    constructor: function (options) {
      // console.log('CircualrChart initialized');
      this._chartViewModel = new CircularChartViewModel(options);
      this._chartView = new CircularChartView({
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
      console.log('Circualrchart disposed');
      this._chartView.dispose();
      this._chartViewModel.dispose();
      this._chartView = undefined;
      this._chartViewModel = undefined;
      this.$el.remove();
      this.$el = undefined;
    },

    onPageReady: function () {
      console.log('onPageReady creating Circualrchart');
      this._chartView.createChart();
    },

    _resolvePromise: function () {
      this._renderDeferred.resolve();
    }

  });

  return CircualrChart;

});
