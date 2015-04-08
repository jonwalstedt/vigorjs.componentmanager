var app = app || {};
app.ComponentFour = Backbone.View.extend({

  initialize: function () {
    console.log('im component four');
  },

  render: function () {
    this.$el.html('Component Four');
    return this;
  },

  dispose: function () {
    this.remove();
  }
});

