var app = app || {};
app.ComponentThree = Backbone.View.extend({

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

