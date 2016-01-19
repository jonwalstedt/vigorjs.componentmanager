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
          label: 'Videos',
          strokeColor: 'rgba(255,255,255,0)',
          fillColor: '#7C87FA',
          highlightFill: 'rgba(250,149,2,0.75)',
          data: this._getRandomData(7)
        },
        {
          label: 'Photos',
          strokeColor: 'rgba(255,255,255,0)',
          fillColor: '#61d6eb',
          highlightFill: 'rgba(250,149,2,0.75)',
          data: this._getRandomData(7)
        },
        {
          label: 'Music',
          strokeColor: 'rgba(255,255,255,0)',
          fillColor: '#5DFFBE',
          highlightFill: 'rgba(250,149,2,0.75)',
          data: this._getRandomData(7)
        }
      ]);
    }

  });

  return LineChartViewModel;

});
