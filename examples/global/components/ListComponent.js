var app = app || {};
app.components = app.components || {};

app.components.ListComponent = Backbone.View.extend({

  className: 'list',
  template: _.template($('script.list-template').html()),
  urlParams: undefined,

  initialize: function (attributes) {
    console.log('Im the ListComponent');
    this.urlParams = attributes.urlParamsModel;
    this.id = this.urlParams.get('params')[0];
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

