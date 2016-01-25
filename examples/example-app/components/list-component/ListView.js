define(function (require) {

  'use strict';

  var ListView,
      $ = require('jquery'),
      _ = require('underscore'),
      Vigor = require('vigor'),
      ComponentViewBase = require('components/ComponentViewBase'),
      listTemplate = require('hbars!./templates/list-template');

  ListView = ComponentViewBase.extend({

    className: 'list-component',
    tagName: 'ul',

    initialize: function (options) {
      ComponentViewBase.prototype.initialize.apply(this, arguments);
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
      this.$el.html(listTemplate(templateData));

      // tmp ugly fix
      this._renderDeferred.resolve();
      if (this.viewModel.listItems.length === 0) {
        this.$el.html('no posts to show');
      }
      // Vigor.EventBus.send(Vigor.EventKeys.COMPONENT_AREAS_ADDED);
      return this;
    },

    addSubscriptions: function () {
      this.viewModel.addSubscriptions();
    },

    removeSubscriptions: function () {
      this.viewModel.removeSubscriptions();
    },

    dispose: function () {
      ComponentViewBase.prototype.dispose.call(this, arguments);
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

  return ListView;

});