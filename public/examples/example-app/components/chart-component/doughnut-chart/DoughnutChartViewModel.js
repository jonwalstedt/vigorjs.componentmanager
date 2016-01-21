define(function (require) {

  'use strict';

  var DoughnutChartViewModel,
      ChartViewModelBase = require('../ChartViewModelBase'),
      Backbone = require('backbone');

  DoughnutChartViewModel = ChartViewModelBase.extend({

    constructor: function (options) {
      ChartViewModelBase.prototype.constructor.apply(this, arguments);

      this.datasetCollection.set([
        {
            value: 100,
            color: '#7C87FA',
            highlight: '#FF5A5E',
            label: 'Red'
        },
        {
            value: 50,
            color: '#61d6eb',
            highlight: '#5AD3D1',
            label: 'Green'
        },
        {
            value: 50,
            color: '#5DFFBE',
            highlight: '#5AD3D1',
            label: 'Green'
        }
      ]);
    },

    getChartData: function () {
      return this.datasetCollection.toJSON();
    }

  });

  return DoughnutChartViewModel;

});
