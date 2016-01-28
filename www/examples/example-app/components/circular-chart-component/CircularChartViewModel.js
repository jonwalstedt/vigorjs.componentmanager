define(function (require) {

  'use strict';

  var CircularChartViewModel,
      Backbone = require('backbone'),
      MathUtil = require('utils/MathUtil'),
      ArcsCollection = require('./ArcsCollection'),
      ComponentViewModel = require('vigor').ComponentViewModel;

  CircularChartViewModel = ComponentViewModel.extend({

    startAngle:  MathUtil.degreesToRadians(-90),

    title: undefined,
    duration: undefined,
    lineWidth: undefined,
    radius: undefined,
    colors: undefined,

    shadowColor: undefined,
    shadowOffsetX: undefined,
    shadowOffsetY: undefined,
    shadowBlur: undefined,

    backgroundArc: {
      angle: MathUtil.degreesToRadians(360),
      radius: undefined
    },

    arcsCollection: undefined,

    constructor: function (options) {
      ComponentViewModel.prototype.constructor.apply(this, arguments);
      this.subscriptionKey = options.subscriptionKey;

      this.title = options.title || 'Chart';
      this.duration = options.duration || 1;
      this.delay = options.delay || 0.2;
      this.lineWidth = options.lineWidth || 35;
      this.radius = options.radius || 100;
      this.backgroundArc.radius = this.radius;
      this.colors = options.colors || ['#f7998e', '#fff4f3', '#f00'];

      this.shadowColor = options.shadowColor || 'rgba(0,0,0,0.4)';
      this.shadowOffsetX = options.shadowOffsetX || 4;
      this.shadowOffsetY = options.shadowOffsetY || 17;
      this.shadowBlur = options.shadowBlur || 50;

      this.arcsCollection = new ArcsCollection();
    },

    getChartData: function () {
      return this.arcsCollection.toJSON();
    },

    addSubscriptions: function () {
      this.subscribe(this.subscriptionKey, _.bind(this._onChartDataChanged, this), {});
    },

    removeSubscriptions: function () {
      this.unsubscribe(this.subscriptionKey);
    },

    dispose: function () {

    },

    _onChartDataChanged: function (data) {
      this.arcsCollection.set(data);
    }


  });

  return CircularChartViewModel;

});
