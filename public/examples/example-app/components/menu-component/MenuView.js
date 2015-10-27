var app = app || {};
app.components = app.components || {};

(function ($) {
  app.components.MenuView = app.components.ComponentViewBase.extend({

    className: 'menu-component',
    componentName: 'menu',
    template: _.template($('script.menu-template').html()),

    renderStaticContent: function () {
      var templateData = {
        menuItems: this.viewModel.menuItems.toJSON()
      }
      this.$el.html(this.template(templateData));
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
})(jQuery);
