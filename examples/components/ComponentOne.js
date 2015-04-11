var app = app || {};
app.ComponentOne = Backbone.View.extend({

  initialize: function (arguments) {
    console.log('im component one', arguments);
  },

  render: function () {
    this.$el.html('Component One');
    return this;
  },

  dispose: function () {
    this.remove();
  }
});

