var app = app || {};
app.components = app.components || {};

app.components.ListComponent = Backbone.View.extend({

  className: 'example-list',
  template: _.template($('script.list-template').html()),
  urlParams: undefined,

  initialize: function (attributes) {
    this.urlParams = attributes.urlParamsModel;
  },

  render: function () {
    id = this.urlParams.get('id') || '';
    this.$el.html(this.template({
      id: id
    }));
    return this;
  },

  dispose: function () {
    this.remove();
  }
});

