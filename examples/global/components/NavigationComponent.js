var app = app || {};
app.components = app.components || {};
app.components.NavigationComponent = Backbone.View.extend({

  template: _.template($('script.navigation-template').html()),
  events: {
    'click a': '_onClick'
  },

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
  },

  _onClick: function () {
    console.log('im being clicked');
  }
});

