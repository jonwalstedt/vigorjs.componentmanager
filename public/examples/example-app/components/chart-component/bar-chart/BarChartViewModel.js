define(function (require) {

  'use strict';

  var BarChartViewModel,
      ChartViewModelBase = require('../ChartViewModelBase'),
      Backbone = require('backbone');

  BarChartViewModel = ChartViewModelBase.extend({

    constructor: function (options) {
      ChartViewModelBase.prototype.constructor.apply(this, arguments);
      this.datasetCollection.set([
        {
          label: 'Some random data',
          fillColor: '#7C87FA',
          highlightFill: 'rgba(250,149,2,0.75)',
          data: this._getRandomData(7)
        }
      ]);
    }
  });

  return BarChartViewModel;

});
