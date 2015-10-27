var app = app || {};
app.components = app.components || {};

(function () {
  'use strict';
  app.components.LineChartViewModel = app.components.ChartViewModelBase.extend({

    constructor: function (options) {
      app.components.ChartViewModelBase.prototype.constructor.apply(this, arguments);
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
})();
