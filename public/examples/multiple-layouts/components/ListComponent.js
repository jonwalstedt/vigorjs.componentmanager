var app = app || {};
app.components = app.components || {};

app.components.ListComponent = Backbone.View.extend({

  className: 'example-list',
  template: _.template($('script.list-template').html()),
  urlParamsModel: undefined,

  initialize: function (attributes) {
    this.urlParamsModel = attributes.urlParamsCollection.at(0);
  },

  render: function () {
    id = this.urlParamsModel.get('id') || '';
    this.$el.html(this.template({
      id: id
    }));
    return this;
  },

  dispose: function () {
    this.remove();
  }
});

