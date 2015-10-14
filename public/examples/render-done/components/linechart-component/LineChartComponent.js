var app = app || {};
app.components = app.components || {};

app.components.LineChartComponent = app.components.BaseComponent.extend({

  className: 'linechart-component',
  template: _.template($('script.linechart-component-template').html()),
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
    console.log('LineChartComponent initialized');
    this.model = new app.components.LineChartModel();
    app.components.BaseComponent.prototype.initialize.call(this);
  },

  render: function () {
    // Fake async data fetching before rendering
    setTimeout(_.bind(function () {
      var canvas;
      this.$el.html(this.template(this.model.toJSON()));
      canvas = $('.linechart-component__canvas', this.$el);
      this.ctx = canvas.get(0).getContext('2d');

      this._renderDeferred.resolve();
      console.log('promise resolved');
    }, this), Math.random()*1000);

    return this;
  },

  onPageReady: function () {
    lineChart = new Chart(this.ctx).Line(this.model.toJSON(), this.chartOptions);
  }
});
