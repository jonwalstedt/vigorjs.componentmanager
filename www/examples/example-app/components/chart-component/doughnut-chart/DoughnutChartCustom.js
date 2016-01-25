define(function (require) {

  'use strict';

  var Chart = require('Chart');

  Chart.types.Doughnut.extend({
    name: "DoughnutCustom",
    draw: function () {
      var ctx = this.chart.ctx;
      ctx.shadowColor = 'rgba(0,0,0,0.8)';
      ctx.shadowOffsetX = 4;
      ctx.shadowOffsetY = -18;
      ctx.shadowBlur = 50;
      Chart.types.Doughnut.prototype.draw.apply(this, arguments);
    }
  });

});