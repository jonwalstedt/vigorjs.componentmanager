var app = app || {};
app.components = app.components || {};

(function () {
  'use strict';
  app.components.BarChartViewModel = app.components.ChartViewModelBase.extend({

    constructor: function (options) {
      app.components.ChartViewModelBase.prototype.constructor.apply(this, arguments);
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
})();
