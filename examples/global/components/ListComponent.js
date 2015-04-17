var app = app || {};
app.components = app.components || {};

app.components.ListComponent = Backbone.View.extend({

  className: 'list',
  template: _.template($('script.list-template').html()),

  initialize: function (attributes) {
    this.id = attributes.urlParams[0]
    console.log('im the ListComponent', this.id);
  },

  render: function () {
    this.$el.html(this.template({
      id: this.id
    }));
    return this;
  },

  dispose: function () {
    this.remove();
  }
});

