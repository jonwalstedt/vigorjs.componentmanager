var app = app || {};
app.components = app.components || {};

app.components.HeaderComponent = app.components.BaseComponent.extend({

  className: 'header-component',
  template: _.template($('script.header-template').html()),

  initialize: function (args) {
    console.log('Header initialized');
    app.components.BaseComponent.prototype.initialize.call(this);
  },

  render: function () {
    this.$el.html(this.template());
    console.log('promise resolved');
    this._renderDeferred.resolve();
    return this;
  }

});
