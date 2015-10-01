var app = app || {};
app.components = app.components || {};

app.components.MarqueeComponent = Backbone.View.extend({

  className: 'marquee',
  template: _.template($('script.marquee-template').html()),

  render: function () {
    this.$el.html(this.template());
    return this;
  },

  dispose: function () {
    this.remove();
  }
});

