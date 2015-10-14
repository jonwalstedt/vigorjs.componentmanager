var app = app || {};
app.components = app.components || {};

app.components.DashboardComponent = app.components.BaseComponent.extend({

  className: 'dashboard-component',
  template: _.template($('script.dashboard-component-template').html()),
  $header: undefined,
  order: undefined,

  initialize: function (args) {
    console.log('DashboardComponent initialized');
    this.order = args.order;
    this.url = args.url;
    this.$el.css({background: args.background});
    this.$el.html(this.template());
    this.$header = $('.dashboard-component__header', this.$el);
    this.$canvas = $('.dashboard-component__canvas', this.$el);
    this.ctx = this.$canvas.get(0).getContext('2d');

    this.data = {
        labels: ["January", "February", "March", "April", "May", "June", "July"],
        datasets: [
          {
            label: "My First dataset",
            fillColor: "rgba(250,149,2,1)",
            highlightFill: "rgba(250,149,2,0.75)",
            data: this.getData(7)
          }
        ]
    };

    app.components.BaseComponent.prototype.initialize.call(this);
  },

  getData: function (nrOfValues) {
    var data = [];
    for(var i = 0; i < nrOfValues; i++) {
      data.push(Math.random()*100);
    }
    console.log(data);
    return data;
  },

  render: function () {
    // Fake async data fetching before rendering

    setTimeout(_.bind(function () {
      markup = '<a href="' + this.url + '">Instance with order: ' + this.order + '</a>';
      this.$header.html(markup);

      barChart = new Chart(this.ctx).Bar(this.data, {
        animation: true,
        animationSteps: 360,
        maintainAspectRatio: false,
        scaleShowGridLines : false,
        barShowStroke : false,
        responsive: true
      });

      this._renderDeferred.resolve();
      console.log('promise resolved');
    }, this), Math.random()*1000);

    return this;
  }
});
