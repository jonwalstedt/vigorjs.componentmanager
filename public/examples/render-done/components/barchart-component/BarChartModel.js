var app = app || {};
app.components = app.components || {};

app.components.BarChartModel = Backbone.Model.extend({

  defaults: {
    id: undefined,
    title: 'BarChart Title',
    labels: [],
    datasets: []
  },

  initialize: function () {
    var labels, datasets;

    labels = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July"
    ];

    datasets = [{
      label: "Some random data",
      fillColor: "rgba(250,149,2,1)",
      highlightFill: "rgba(250,149,2,0.75)",
      data: this.getRandomData(7)
    }];

    this.set({labels: labels, datasets: datasets});
  },

  getRandomData: function (nrOfValues) {
    var data = [];
    for(var i = 0; i < nrOfValues; i++) {
      data.push(Math.random()*100);
    }
    return data;
  }
});