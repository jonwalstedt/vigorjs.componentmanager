define(function (require) {

  'use strict';

  var ListViewModel,
      Backbone = require('backbone'),
      ComponentViewModel = require('vigor').ComponentViewModel;

  ListViewModel = ComponentViewModel.extend({

    listItems: undefined,

    constructor: function (options) {
      ComponentViewModel.prototype.constructor.apply(this, arguments);
      this.subscriptionKey = options.subscriptionKey;
      this.listItems = new Backbone.Collection();
    },

    addSubscriptions: function () {
      this.subscribe(this.subscriptionKey, _.bind(this._onListItemsChanged, this), {});
    },

    removeSubscriptions: function () {
      this.unsubscribe(this.subscriptionKey);
    },

    _onListItemsChanged: function (listItems) {
      this.listItems.reset(listItems);
    }

  });

  return ListViewModel;

});
