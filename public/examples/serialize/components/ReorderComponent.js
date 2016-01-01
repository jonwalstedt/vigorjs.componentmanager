var app = app || {};
app.components = app.components || {};

app.components.ReorderComponent = Backbone.View.extend({

  order: undefined,
  className: 'reorder-component',

  initialize: function (args) {
    console.log('component initialized', args);
    this.order = args.order;
    this.background = args.background;
  },

  render: function () {
    this.$el.css("background", this.background);
    markup = '<h2>Instance with order: ' + this.order + '</h2>';
    this.$el.html(markup);
    return this;
  },

  dispose: function () {
    console.log('component disposed');
    this.remove();
  }

});
