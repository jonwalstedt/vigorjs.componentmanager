var app = app || {};
app.components = app.components || {};

(function ($) {
  'use strict';
  app.components.ListView = app.components.ComponentViewBase.extend({

    className: 'list-component',
    tagName: 'ul',
    componentName: 'list',
    template: _.template($('script.list-template').html()),

    initialize: function (options) {
      app.components.ComponentViewBase.prototype.initialize.apply(this, arguments);
      this.listenTo(this.viewModel.listItems, 'reset', this.renderDynamicContent);
    },

    renderStaticContent: function () {
      this.$el.html('Loading items...');
      return this;
    },

    // TODO: do same approach as in hello-world example,
    // this triggers once fore each item and will cause multiple rerenders
    renderDynamicContent: function () {
      var templateData = {
        listItems: this.viewModel.listItems.toJSON()
      };
      this.$el.html(this.template(templateData));
      this._renderDeferred.resolve();
      Vigor.EventBus.send(Vigor.EventKeys.COMPONENT_AREAS_ADDED);
      return this;
    },

    addSubscriptions: function () {
      this.viewModel.addSubscriptions();
    },

    removeSubscriptions: function () {
      this.viewModel.removeSubscriptions();
    },

    dispose: function () {
      app.components.ComponentViewBase.prototype.dispose.call(this, arguments);
    },

    _onListItemsAdd: function (addedItem, collection, options) {
      console.log(addedItem, collection, options);
      // var helloWorldItemModel = new app.HelloWorldItemViewModel(addedItem.id),
      //     helloWorldItemView = new app.HelloWorldItemView({ viewModel: helloWorldItemModel });

      // helloWorldItemView.render();
      // this._helloWorldItems.push(helloWorldItemView);
      // this.renderDynamicContent();
    },

    _onListItemsRemove: function (removedItem, collection, options) {
      // var removedComponent = this._helloWorldItems.splice(options.index, 1)[0];

      // if (removedComponent) {
      //   removedComponent.el.remove();
      //   removedComponent.dispose();
      // }
    }
  });
})(jQuery);