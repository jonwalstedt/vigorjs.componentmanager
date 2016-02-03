define(function (require) {

  'use strict';

  var MediaPlayerViewModel,
      subscriptionKeys = require('SubscriptionKeys'),
      ComponentViewModel = require('vigor').ComponentViewModel;

  MediaPlayerViewModel = ComponentViewModel.extend({

    constructor: function (options) {
      this.fileModel = new Backbone.Model();
      ComponentViewModel.prototype.constructor.apply(this, arguments);
    },

    addSubscriptions: function (id) {
      this.subscribe(subscriptionKeys.FILE, _.bind(this._onFileChange, this), {id: id});
    },

    removeSubscriptions: function () {
      this.unsubscribe(subscriptionKeys.FILE);
    },

    _onFileChange: function (fileData) {
      this.fileModel.set(fileData);
    }
  });

  return MediaPlayerViewModel;

});
