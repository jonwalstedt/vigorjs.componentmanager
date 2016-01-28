define(function (require) {

  'use strict';

  var ListViewModel,
      _ = require('underscore'),
      Backbone = require('backbone'),
      ComponentViewModel = require('vigor').ComponentViewModel,
      ListItemsCollection = require('./ListItemsCollection');

  ListViewModel = ComponentViewModel.extend({

    listItems: undefined,
    filesPerPage: 20,

    constructor: function (options) {
      ComponentViewModel.prototype.constructor.apply(this, arguments);
      this.subscriptionKey = options.subscriptionKey;
      this.listItems = new ListItemsCollection();
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

  return ListViewModel;

});
