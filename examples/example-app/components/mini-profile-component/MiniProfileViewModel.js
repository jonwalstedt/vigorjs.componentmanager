define(function (require) {

  'use strict';

  var MiniProfileViewModel,
      subscriptionKeys = require('SubscriptionKeys'),
      ComponentViewModel = require('vigor').ComponentViewModel;

  MiniProfileViewModel = ComponentViewModel.extend({

    userModel: undefined,

    constructor: function (options) {
      this.userModel = new Backbone.Model();
      ComponentViewModel.prototype.constructor.apply(this, arguments);
    },

    addSubscriptions: function () {
      this.subscribe(subscriptionKeys.USER_PROFILE, _.bind(this._onProfileChange, this), {});
    },

    removeSubscriptions: function () {
      this.unsubscribe(this.subscriptionKey);
    },

    _onProfileChange: function (userData) {
      this.userModel.set(userData);
    }
  });

  return MiniProfileViewModel;

});
