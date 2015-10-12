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

    this.$el.html(this.template());
    this.$header = $('.dashboard-component__header', this.$el);

    app.components.BaseComponent.prototype.initialize.call(this);
  },

  render: function () {
    // Fake async data fetching before rendering

    setTimeout(_.bind(function () {
      markup = '<a href="' + this.url + '">Instance with order: ' + this.order + '</a>';
      this.$header.html(markup);

      this._renderDeferred.resolve();
      console.log('promise resolved');
    }, this), Math.random()*200);

    return this;
  }
});
