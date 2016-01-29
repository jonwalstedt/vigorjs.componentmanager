define(function (require) {

  'use strict';

  var FileListViewModel,
      _ = require('underscore'),
      Backbone = require('backbone'),
      ComponentViewModel = require('vigor').ComponentViewModel,
      FileListItemsCollection = require('./FileListItemsCollection'),
      subscriptionKeys = require('SubscriptionKeys');

  FileListViewModel = ComponentViewModel.extend({

    listItems: undefined,
    subscriptionKey: subscriptionKeys.FILES,

    constructor: function (options) {
      ComponentViewModel.prototype.constructor.apply(this, arguments);
      this.listItems = new FileListItemsCollection();
    },

    addSubscriptions: function () {
      this.subscribe(this.subscriptionKey, _.bind(this._onListItemsChanged, this), {});
    },

    removeSubscriptions: function () {
      this.unsubscribe(this.subscriptionKey);
    },

    paginateListItems: function (currentPage) {
      return this.listItems.paginate(currentPage);
    },

    _onListItemsChanged: function (listItems) {
      this.listItems.reset(listItems);
    }

  });

  return FileListViewModel;

});
