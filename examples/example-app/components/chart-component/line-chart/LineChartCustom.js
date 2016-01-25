define(function (require) {

  'use strict';

  var Chart = require('Chart');

  Chart.types.Line.extend({
    name: "LineCustom",
    draw: function () {
      var ctx = this.chart.ctx;
      ctx.shadowColor = 'rgba(0,0,0,0.4)';
      ctx.shadowOffsetX = 4;
      ctx.shadowOffsetY = -18;
      ctx.shadowBlur = 50;
      Chart.types.Line.prototype.draw.apply(this, arguments);
    }
  });

});