define(function (require) {

  'use strict';

  var BarChartViewModel,
      ChartViewModelBase = require('../ChartViewModelBase'),
      Backbone = require('backbone');

  BarChartViewModel = ChartViewModelBase.extend({

    constructor: function (options) {
      ChartViewModelBase.prototype.constructor.apply(this, arguments);
      this._datasetCollection = new Backbone.Collection([
        {
          label: 'Some random data',
          fillColor: "rgba(250,149,2,1)",
          highlightFill: "rgba(250,149,2,0.75)",
          data: this._getRandomData(7)
        }
      ]);
    }
  });

  return BarChartViewModel;

});
