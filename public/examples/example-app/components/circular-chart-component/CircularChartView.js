define(function (require) {

  'use strict';

  var CircularChartView,
      Backbone = require('backbone'),
      TweenMax = require('TweenMax'),
      ColorUtil = require('utils/ColorUtil'),
      ComponentViewBase = require('components/ComponentViewBase'),
      chartTemplate = require('hbars!./templates/circular-chart-template');

  CircularChartView = ComponentViewBase.extend({

    className: 'chart-component circular-chart-component',

    constructor: function () {
      Backbone.View.prototype.constructor.apply(this, arguments);
    },

    initialize: function () {
      ComponentViewBase.prototype.initialize.apply(this, arguments);
    },

    renderStaticContent: function () {
      this.$el.html(chartTemplate());

      this.$chart = $('.chart-component__chart', this.$el);
      this.$canvas = $('.chart-component__canvas', this.$el);
      this.$title = $('.chart-component__title', this.$el);
      this.$usedValue = $('.chart-component__used-value', this.$el);
      this.$usedSuffix = $('.chart-component__used-suffix', this.$el);
      this.$statsTotal = $('.chart-component__stats-used', this.$el);
      this.$statsUsed = $('.chart-component__stats-total', this.$el);
      this.$statsLimit = $('.chart-component__stats-limit', this.$el);

      this.$title.text(this.viewModel.title);
      this.canvas = this.$canvas.get(0);
      this.ctx = this.canvas.getContext('2d');

      this._renderDeferred.resolve();
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
      $(window).off('resize', _.bind(this._onResize, this));
    },

    createChart: function () {
      $(window).on('resize', _.bind(this._onResize, this));
      this.listenTo(this.viewModel.arcsCollection, 'change:targetAngle', _.bind(this._onTargetAngleChanged, this));
      this._updateDimensions();
      this._animateArcs();
    },

    _animateArcs: function () {
      this._arcs = this.viewModel.arcsCollection.toJSON();

      for (var i = 0; i < this._arcs.length; i++) {
        var arc = this._arcs[i];
        TweenLite.to(arc, this.viewModel.duration, {
          angle: arc.targetAngle,
          percent: arc.targetPercent,
          used: arc.targetUsed,
          onUpdate: _.bind(this._draw, this),
          onComplete: _.bind(this._onAnimationComplete, this),
          delay: i
        });
      };
    },

    _draw: function () {
      this.ctx.lineWidth = this.viewModel.lineWidth;
      this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);

      this._drawArc(0, this.viewModel.backgroundArc);
      this._updateStats();

      for (var i = 0; i < this._arcs.length; i++) {
        var arc = this._arcs[i];
        this._drawArc(i+1, arc);
      };

    },

    _drawArc: function (index, arc) {
      var color = this.viewModel.colors[index] || '#f00',
          darkenedColor = ColorUtil.shadeBlendConvert(-0.4, color),
          linearGradient = this.ctx.createLinearGradient(0, 0, 0, this.canvas.height);

      linearGradient.addColorStop(0, color);
      linearGradient.addColorStop(1, darkenedColor);

      this.ctx.shadowColor = this.viewModel.shadowColor;
      this.ctx.shadowOffsetX = this.viewModel.shadowOffsetX;
      this.ctx.shadowOffsetY = this.viewModel.shadowOffsetY;
      this.ctx.shadowBlur = this.viewModel.shadowBlur;
      this.ctx.strokeStyle = linearGradient;

      this.ctx.beginPath();
      this.ctx.arc(this.canvas.width / 2, this.canvas.height / 2, this.viewModel.radius + ((index + 1) * 10), this.viewModel.startAngle, this.viewModel.startAngle + arc.angle);
      this.ctx.stroke();
    },

    _updateStats: function () {
      var arc = this._arcs[1],
          arcTotal = this._arcs[0],
          usedValue = Math.round(arc.used),
          total = Math.round(arcTotal.used),
          totalSuffix = arcTotal.usedSuffix,
          used = Math.round(arc.used),
          usedSuffix = arc.usedSuffix;

      this.$usedValue.text(usedValue);
      this.$usedSuffix.text(usedSuffix);

      this.$statsTotal.text('files: ' + total + ' ' + totalSuffix);
      this.$statsUsed.text(arc.id + ': ' + used + ' ' + usedSuffix);
      this.$statsLimit.text('limit:' + arc.limit + ' ' + arc.limitSuffix);
    },

    _updateDimensions: function () {
      this.$canvas.attr('width', this.$chart.width());
      this.$canvas.attr('height', this.$chart.height());
    },

    _onAnimationComplete: function () {
      this.viewModel.arcsCollection.set(this._arcs, {silent: true});
    },

    _onResize: function () {
      this._updateDimensions();
      this._draw();
    },

    _onTargetAngleChanged: function (model) {
      this._animateArcs();
    }
  });

  return CircularChartView;

});