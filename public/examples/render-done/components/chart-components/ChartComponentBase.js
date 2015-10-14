var app = app || {};
app.components = app.components || {};
app.simulatedCache = app.simulateCache || {};

app.components.ChartComponentBase = app.components.BaseComponent.extend({

  template: _.template($('script.chart-component-template').html()),
  model: undefined,
  chartOptions: undefined,
  chart: undefined,

  render: function () {
    // Fake async data fetching before rendering
    var loadTime = Math.random() * 1000;
    if (app.simulatedCache[this.componentName]) {
      loadTime = 0;
    }

    setTimeout(_.bind(function () {
      var canvas;
      this.$el.html(this.template(this.model.toJSON()));
      canvas = $('.chart-component__canvas', this.$el);
      this.ctx = canvas.get(0).getContext('2d');

      this._renderDeferred.resolve();
      console.log('promise resolved');
      app.simulatedCache[this.componentName] = true;
    }, this), loadTime);

    return this;
  },

  dispose: function () {
    if (this.chart) {
      this.chart.destroy();
    }
    app.components.BaseComponent.prototype.dispose.call(this);
  }
});
