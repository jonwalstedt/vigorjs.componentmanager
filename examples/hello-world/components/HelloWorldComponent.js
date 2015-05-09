var app = app || {};
app.components = app.components || {};

app.components.HelloWorldComponent = Backbone.View.extend({
  constructor: function () {
    console.log('hello world component instantiated');
    Backbone.View.prototype.constructor.call(this);
  },

  render: function () {
    this.$el.html('Hello World');
    return this;
  },

  dispose: function () {
    this.remove();
    console.log('hello world component disposed');
  }
});

