var app = app || {};
app.components = app.components || {};

app.components.LineChartComponent = app.components.ChartComponentBase.extend({

  className: 'linechart-component',
  componentName: 'line-chart',
  model: undefined,

  chartOptions: {
    animation: true,
    animationSteps: 360,
    maintainAspectRatio: false,
    scaleShowGridLines : true,
    scaleGridLineColor : "rgba(0,0,0,.9)",
    scaleGridLineWidth : 1,
    scaleShowHorizontalLines: false,
    scaleShowVerticalLines: true,
    responsive: true
  },

  initialize: function (args) {
    console.log('LineChartComponent initialized');
    this.model = new app.components.LineChartModel();
    app.components.BaseComponent.prototype.initialize.call(this);
  },

  onPageReady: function () {
    this.chart = new Chart(this.ctx).Line(this.model.toJSON(), this.chartOptions);
  }
});
