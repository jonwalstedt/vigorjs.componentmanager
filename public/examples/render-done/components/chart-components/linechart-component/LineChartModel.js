var app = app || {};
app.components = app.components || {};

app.components.LineChartModel = app.components.ChartModelBase.extend({

  initialize: function () {
    var datasets = [{
      label: "Some random data",
      strokeColor: "rgb(150, 235, 89)",
      fillColor: "rgba(125, 199, 72, 0.3)",
      highlightFill: "rgba(250,149,2,0.75)",
      data: this.getRandomData(7)
    }];

    this.set({
      title: 'LineChart Title',
      datasets: datasets
    });
    app.components.ChartModelBase.prototype.initialize.call(this);
  }

});