var app = app || {};
app.components = app.components || {};

app.components.ComponentTwo = Backbone.View.extend({

  initialize: function () {
    console.log('im component two');
  },

  render: function () {
    this.$el.html('Component Two');
    return this;
  },

  dispose: function () {
    this.remove();
  }
});

