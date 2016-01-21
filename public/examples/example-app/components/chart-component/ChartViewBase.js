define(function (require) {

  'use strict';

  var ChartViewBase,
      $ = require('jquery'),
      ColorUtil = require('utils/ColorUtil'),
      ComponentViewBase = require('components/ComponentViewBase'),
      chartTemplate = require('hbars!./templates/chart-template');

  ChartViewBase = ComponentViewBase.extend({

    className: 'chart-component',
    model: undefined,

    renderStaticContent: function () {
      var templateData = {
        title: this.viewModel.title
      };

      this.$el.html(chartTemplate(templateData));
      this.$canvas = $('.chart-component__canvas', this.$el);
      this.ctx = this.$canvas.get(0).getContext('2d');

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

    tweakColors: function (datasets, dimFirst) {
      for (var i = 0; i < datasets.length; i++) {
        var set = datasets[i],
            linearGradient = this.ctx.createLinearGradient(0, 0, 0, this.$canvas.height()),
            colorObj = ColorUtil.sbcRip(set.fillColor),
            alpha = i == 0 && dimFirst ? 0.1 : 0.6,
            darkenedAlpha = i == 0 && dimFirst ? 0.3 : 0.9,
            lightenedAlpha = i == 0 && dimFirst ? 0.3 : 0.5,
            color = 'rgba(' + colorObj[0] + ', ' + colorObj[1] + ', ' + colorObj[2] + ', ' + alpha +')',
            darkenedColorObj = ColorUtil.sbcRip(ColorUtil.shadeBlendConvert(-0.4, set.fillColor)),
            lightenedColorObj = ColorUtil.sbcRip(ColorUtil.shadeBlendConvert(0.4, set.fillColor)),
            darkenedColor = 'rgba(' + darkenedColorObj[0] + ', ' + darkenedColorObj[1] + ', ' + darkenedColorObj[2] + ', ' + darkenedAlpha +')',
            lightenedColor = 'rgba(' + lightenedColorObj[0] + ', ' + lightenedColorObj[1] + ', ' + lightenedColorObj[2] + ', ' + lightenedAlpha +')';

        linearGradient.addColorStop(0, color);
        linearGradient.addColorStop(1, darkenedColor);

        set.strokeColor = lightenedColor;
        set.fillColor = linearGradient;
      };
    },

    // Im a noop
    createChart: function () {}
  });

  return ChartViewBase;

});