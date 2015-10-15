var app = app || {};
app.components = app.components || {};

app.components.BarChartComponent = app.components.ChartComponentBase.extend({

  className: 'barchart-component',
  componentName: 'bar-chart',
  model: undefined,

  chartOptions: {
    animation: true,
    animationSteps: 360,
    maintainAspectRatio: false,
    scaleShowGridLines : false,
    barShowStroke : false,
    responsive: true
  },

  initialize: function (args) {
    console.log('BarChartComponent initialized');
    this.model = new app.components.BarChartModel();
    app.components.BaseComponent.prototype.initialize.call(this);
  },

  onPageReady: function () {
    if (!this.chart) {
      this.chart = new Chart(this.ctx).Bar(this.model.toJSON(), this.chartOptions);
    }
  }
});
