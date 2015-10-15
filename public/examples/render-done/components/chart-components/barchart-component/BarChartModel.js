var app = app || {};
app.components = app.components || {};

app.components.BarChartModel = app.components.ChartModelBase.extend({

  initialize: function () {
    var datasets = [{
      label: "Some random data",
      fillColor: "rgba(250,149,2,1)",
      highlightFill: "rgba(250,149,2,0.75)",
      data: this.getRandomData(7)
    }];

    this.set({
      title: 'BarChart Title',
      datasets: datasets
    });
    app.components.ChartModelBase.prototype.initialize.call(this);
  }
});