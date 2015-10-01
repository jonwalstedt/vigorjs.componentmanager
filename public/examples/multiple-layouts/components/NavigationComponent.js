var app = app || {};
app.components = app.components || {};

app.components.NavigationComponent = Backbone.View.extend({

  tagName: 'nav',
  className: 'navigation',
  template: _.template($('script.navigation-template').html()),

  render: function () {
    this.$el.html(this.template());
    return this;
  },

  dispose: function () {
    this.remove();
  },

});

