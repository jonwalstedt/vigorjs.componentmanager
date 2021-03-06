define(function (require) {

  'use strict';

  var BarChartViewModel,
      ChartViewModelBase = require('../ChartViewModelBase'),
      Backbone = require('backbone');

  BarChartViewModel = ChartViewModelBase.extend({

    onChartDataChanged: function (data) {
      // Add colors to the data sets
      for (var i = 0; i < data.datasets.length; i++) {
        if (this.colors[i]) {
          data.datasets[i].fillColor = this.colors[i];
        } else {
          data.datasets[i].fillColor = '#fff';
        }
      };

      this.labels.set('labels', data.labels);
      this.datasetCollection.set(data.datasets);
    }
  });

  return BarChartViewModel;

});
