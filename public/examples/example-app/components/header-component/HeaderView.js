var app = app || {};
app.components = app.components || {};

app.components.HeaderView = app.components.ComponentViewBase.extend({

  className: 'header-component',
  componentName: 'header',
  template: _.template($('script.header-template').html()),

  renderStaticContent: function () {
    this.$el.html(this.template());
    this._renderDeferred.resolve();
    return this;
  },

  renderDynamicContent: function () {},

  addSubscriptions: function () {},

  removeSubscriptions: function () {},

  dispose: function () {
    app.components.ComponentViewBase.prototype.dispose.apply(this, arguments);
  }

});
