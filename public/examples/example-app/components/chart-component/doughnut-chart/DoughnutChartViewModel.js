var app = app || {};
app.components = app.components || {};

(function () {
  'use strict';
  app.components.DoughnutChartViewModel = app.components.ChartViewModelBase.extend({

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
    },
    getChartData: function () {
      var data = [
        {
            value: 300,
            color:"#F7464A",
            highlight: "#FF5A5E",
            label: "Red"
        },
        {
            value: 50,
            color: "#46BFBD",
            highlight: "#5AD3D1",
            label: "Green"
        },
        {
            value: 100,
            color: "#FDB45C",
            highlight: "#FFC870",
            label: "Yellow"
        }
      ]
      return data;
    }

  });
})();
