define(function (require) {

  'use strict';

  var ChartViewModelBase,
      Backbone = require('backbone'),
      ComponentViewModel = require('vigor').ComponentViewModel;

  ChartViewModelBase = ComponentViewModel.extend({

    title: undefined,
    datasetCollection: undefined,
    labels: undefined,

    constructor: function (options) {
      this.subscriptionKey = options.subscriptionKey;
      this.colors = options.colors || ['#f7998e', '#fff4f3', '#f00'];
      this.title = options.title || 'EXAMPLE, FIX ME';
      this.datasetCollection = new Backbone.Collection();
      this.labels = new Backbone.Model({labels: []});

      ComponentViewModel.prototype.constructor.apply(this, arguments);
    },

    getChartData: function () {
      var data = {
        labels: this.labels.toJSON().labels,
        datasets: this.datasetCollection.toJSON()
      }
      return data;
    },

    addSubscriptions: function () {
      this.subscribe(this.subscriptionKey, _.bind(this.onChartDataChanged, this), {});
    },

    removeSubscriptions: function () {
      this.unsubscribe(this.subscriptionKey);
    },

    onChartDataChanged: function (data) {
      this.labels.set('labels', data.labels);
      this.datasetCollection.set(data.datasets);
    }
  });

  return ChartViewModelBase;

});
