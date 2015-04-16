var app = app || {};
app.components = app.components || {};

app.components.ListComponent = Backbone.View.extend({

  className: 'list',
  template: _.template($('script.list-template').html()),

  initialize: function () {
    console.log('im the ListComponent');
  },

  render: function () {
    this.$el.html(this.template());
    return this;
  },

  dispose: function () {
    this.remove();
  }
});

