define(function (require) {

  'use strict';

  var ChartViewBase,
      $ = require('jquery'),
      _ = require('underscore'),
      ComponentViewBase = require('components/ComponentViewBase');

  ChartViewBase = ComponentViewBase.extend({

    className: 'chart-component',
    model: undefined,
    template: _.template($('script.chart-component-template').html()),

    chartOptions: undefined,

    initialize: function (options) {
      ComponentViewBase.prototype.initialize.apply(this, arguments);
    },

    renderStaticContent: function () {
      var templateData = {
            title: this.viewModel.getTitle()
          },
          $canvas;

      this.$el.html(this.template(templateData));
      $canvas = $('.chart-component__canvas', this.$el);
      this.ctx = $canvas.get(0).getContext('2d');

      this._renderDeferred.resolve();
      return this;
    },

    renderDynamicContent: function () {
      return this;
    },

    addSubscriptions: function () {
      this.viewModel.addSubscriptions();
    },

    removeSubscriptions: function () {
      this.viewModel.removeSubscriptions();
    },

    dispose: function () {
      ComponentViewBase.prototype.dispose.apply(this, null);
    },

    // Im a noop
    createChart: function () {}
  });

  return ChartViewBase;

});