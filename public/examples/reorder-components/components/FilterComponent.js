var app = app || {};
app.components = app.components || {};

app.components.FilterComponent = Backbone.View.extend({

  order: undefined,

  initialize: function (args) {
    console.log('component initialized', arguments);
    this.order = args.order;
    this.$el.css("background", args.background);
  },

  render: function () {
    markup = '<h3>Instance with order: ' + this.order + '</h3>';
    this.$el.html(markup);
    this.$order = this.$el.find('.order');
    return this;
  },

  dispose: function () {
    console.log('component disposed');
    console.trace();
    this.remove();
  }

});
