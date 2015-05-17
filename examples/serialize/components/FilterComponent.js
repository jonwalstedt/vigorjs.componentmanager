var app = app || {};
app.components = app.components || {};

app.components.FilterComponent = Backbone.View.extend({

  title: undefined,

  initialize: function (args) {
    console.log('component initialized');
    this.title = args.title;
    this.background = args.background;
  },

  render: function () {
    this.$el.css("background", this.background);
    markup = '<h2>Example component: ' + this.title + '</h2>';
    this.$el.html(markup);
    return this;
  },

  dispose: function () {
    console.log('component disposed');
    this.remove();
  }

});
