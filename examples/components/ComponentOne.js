var app = app || {};
app.ComponentOne = Backbone.View.extend({

  initialize: function () {
    console.log('im component one');
  },

  render: function () {
    this.$el.html('Component One');
    return this;
  }
});

