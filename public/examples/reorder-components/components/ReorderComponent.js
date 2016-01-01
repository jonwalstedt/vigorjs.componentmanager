var app = app || {};
app.components = app.components || {};

app.components.ReorderComponent = Backbone.View.extend({

  order: undefined,
  className: 'reorder-component',

  initialize: function (args) {
    console.log('component initialized', arguments);
    this.order = args.order;
    this.$el.css("background", args.background);
  },

  render: function () {
    markup = '<h2>Instance with order: ' + this.order + '</h2>';
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
