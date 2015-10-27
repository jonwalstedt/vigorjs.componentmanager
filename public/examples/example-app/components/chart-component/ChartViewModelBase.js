var app = app || {};
app.components = app.components || {};

(function () {
  'use strict';
  app.components.ChartViewModelBase = Vigor.ComponentViewModel.extend({

    title: undefined,
    _labels: undefined,
    _datasetCollection: undefined,

    constructor: function (options) {
      this._labels = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July'
      ];

      this._datasetCollection = new Backbone.Collection([
        {
          label: 'Some random data',
          fillColor: "rgba(250,149,2,1)",
          highlightFill: "rgba(250,149,2,0.75)",
          data: this._getRandomData(7)
        }
      ]);

      this._title = 'EXAMPLE, FIX ME';

      this.subscriptionKey = options.subscriptionKey;
      Vigor.ComponentViewModel.prototype.constructor.apply(this, arguments);
    },

    getTitle: function () {
      return this._title;
    },

    getChartData: function () {
      var data = {
        labels: this._labels,
        datasets: this._datasetCollection.toJSON()
      }
      return data;
    },

    addSubscriptions: function () {
      // this.subscribe(this.subscriptionKey, _.bind(this._onChartDataChanged, this), {});
    },

    removeSubscriptions: function () {
      // this.unsubscribe(this.subscriptionKey);
    },

    _getRandomData: function (nrOfValues) {
      var data = [];
      for(var i = 0; i < nrOfValues; i++) {
        data.push(Math.random()*100);
      }
      return data;
    },

    _onChartDataChanged: function () {
      console.log('_onChartDataChanged');
    }

  });
})();
