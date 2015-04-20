var app = app || {};
app.components = app.components || {};

app.components.ListComponent = Backbone.View.extend({

  className: 'list',
  template: _.template($('script.list-template').html()),
  urlParams: undefined,

  initialize: function (attributes) {
    console.log('Im the ListComponent', attributes);
    this.urlParams = attributes.urlParamsModel;
  },

  render: function () {
    id = this.urlParams.get('params') || '';
    this.$el.html(this.template({
      id: id
    }));
    return this;
  },

  dispose: function () {
    this.remove();
  }
});

