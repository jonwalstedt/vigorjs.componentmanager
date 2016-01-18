define(function (require) {

  'use strict';

  var UserProfileProducer,
      MathUtil = require('utils/MathUtil'),
      AccountTypes = require('app/AccountTypes'),
      BaseProducer = require('./BaseProducer'),
      UsersRepository = require('repositories/users/UsersRepository'),
      subscriptionKeys = require('SubscriptionKeys');

  UserProfileProducer = BaseProducer.extend({

    PRODUCTION_KEY: subscriptionKeys.USER_PROFILE,
    repositories: [UsersRepository],

    repoFetchSubscription: undefined,

    subscribeToRepositories: function () {
      BaseProducer.prototype.subscribeToRepositories.call(this);

      this.repoFetchSubscription = {
        pollingInterval: 1000 * 10,
        params: {}
      };

      UsersRepository.addSubscription(UsersRepository.ALL, this.repoFetchSubscription);
    },

    unsubscribeFromRepositories: function () {
      BaseProducer.prototype.unsubscribeFromRepositories.call(this);
      UsersRepository.removeSubscription(UsersRepository.ALL, this.repoFetchSubscription);
    },

    currentData: function () {
      var user = UsersRepository.getLoggedInUser(),
          limit = AccountTypes.premium.bytesLimit;

      user.usedPercentage = (user.bytesUsed / limit) * 100;
      user.usedFormatted = MathUtil.formatBytes(user.bytesUsed, 2).string;
      user.limitFormatted = MathUtil.formatBytes(limit, 2).string;

      return user;
    }

  });

  return UserProfileProducer;

});
