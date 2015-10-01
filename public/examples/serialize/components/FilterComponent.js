var app = app || {};
app.components = app.components || {};

app.components.FilterComponent = Backbone.View.extend({

  order: undefined,

  initialize: function (args) {
    console.log('component initialized', args);
    this.order = args.order;
    this.background = args.background;
  },

  render: function () {
    this.$el.css("background", this.background);
    markup = '<h3>Instance with order: ' + this.order + '</h3>';
    this.$el.html(markup);
    return this;
  },

  dispose: function () {
    console.log('component disposed');
    this.remove();
  }

});
