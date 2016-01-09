define(function (require) {

  'use strict';

  var LineChartViewModel,
      ChartViewModelBase = require('../ChartViewModelBase'),
      Backbone = require('backbone');

  LineChartViewModel = ChartViewModelBase.extend({

    constructor: function (options) {
      ChartViewModelBase.prototype.constructor.apply(this, arguments);
      this._datasetCollection = new Backbone.Collection([
        {
          label: 'Some random data',
          strokeColor: 'rgb(150, 235, 89)',
          fillColor: 'rgba(125, 199, 72, 0.3)',
          highlightFill: 'rgba(250,149,2,0.75)',
          data: this._getRandomData(7)
        }
      ]);
    }

  });

  return LineChartViewModel;

});
