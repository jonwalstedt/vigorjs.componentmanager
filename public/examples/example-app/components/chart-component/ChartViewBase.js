define(function (require) {

  'use strict';

  var ChartViewBase,
      $ = require('jquery'),
      ComponentViewBase = require('components/ComponentViewBase'),
      chartTemplate = require('hbars!./templates/chart-template');

  ChartViewBase = ComponentViewBase.extend({

    className: 'chart-component',
    model: undefined,

    chartOptions: undefined,

    initialize: function (options) {
      ComponentViewBase.prototype.initialize.apply(this, arguments);
    },

    renderStaticContent: function () {
      var templateData = {
            title: this.viewModel.getTitle()
          },
          $canvas;

      this.$el.html(chartTemplate(templateData));
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