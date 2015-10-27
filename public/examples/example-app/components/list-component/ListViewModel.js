var app = app || {};
app.components = app.components || {};

(function ($) {
  'use strict';
  var SubscriptionKeys = Vigor.SubscriptionKeys;
  app.components.ListViewModel = Vigor.ComponentViewModel.extend({

    listItems: undefined,

    constructor: function (options) {
      Vigor.ComponentViewModel.prototype.constructor.apply(this, arguments);
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
})(jQuery);
