var app = app || {};
app.components = app.components || {};

app.components.LineChartModel = Backbone.Model.extend({

  defaults: {
    id: undefined,
    title: 'LineChart Title',
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
      // {
      //       label: "My First dataset",
      //       fillColor: "rgba(220,220,220,0.2)",
      //       strokeColor: "rgba(220,220,220,1)",
      //       pointColor: "rgba(220,220,220,1)",
      //       pointStrokeColor: "#fff",
      //       pointHighlightFill: "#fff",
      //       pointHighlightStroke: "rgba(220,220,220,1)",
      //       data: [65, 59, 80, 81, 56, 55, 40]
      //   }
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