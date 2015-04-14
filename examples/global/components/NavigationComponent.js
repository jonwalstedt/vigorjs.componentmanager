var app = app || {};
app.components = app.components || {};
app.components.NavigationComponent = Backbone.View.extend({

  template: _.template($('script.navigation-template').html()),

  initialize: function () {
    console.log('im the navigation component');
    this.render();
  },

  render: function () {
    this.$el.html(this.template());
    return this;
  },

  dispose: function () {
    this.remove();
  }
});

