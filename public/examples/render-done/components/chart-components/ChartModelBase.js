var app = app || {};
app.components = app.components || {};

app.components.ChartModelBase = Backbone.Model.extend({

  defaults: {
    id: undefined,
    title: 'LineChart Title',
    labels: [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July"
    ],
    datasets: []
  },

  getRandomData: function (nrOfValues) {
    var data = [];
    for(var i = 0; i < nrOfValues; i++) {
      data.push(Math.random()*100);
    }
    return data;
  }
});