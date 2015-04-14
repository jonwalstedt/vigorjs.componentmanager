var app = app || {};
app.components = app.components || {};

app.components.ComponentThree = Backbone.View.extend({

  initialize: function () {
    console.log('im component three');
  },

  render: function () {
    this.$el.html('Component Three');
    return this;
  },

  dispose: function () {
    this.remove();
  }
});

