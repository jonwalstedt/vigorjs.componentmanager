var app = app || {};
app.components = app.components || {};

app.components.MenuComponent = app.components.BaseComponent.extend({

  className: 'menu-component',
  template: _.template($('script.menu-template').html()),

  initialize: function (args) {
    console.log('Menu initialized');
    app.components.BaseComponent.prototype.initialize.call(this);
  },

  render: function () {
    this.$el.html(this.template());
    console.log('promise resolved');
    this._renderDeferred.resolve();
    return this;
  }
});
