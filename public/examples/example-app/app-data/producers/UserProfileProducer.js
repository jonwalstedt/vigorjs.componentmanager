define(function (require) {

  'use strict';

  var UserProfileProducer,
      Producer = require('vigor').Producer,
      UsersRepository = require('repositories/users/UsersRepository'),
      subscriptionKeys = require('SubscriptionKeys');

  UserProfileProducer = Producer.extend({

    PRODUCTION_KEY: subscriptionKeys.USER_PROFILE,
    repositories: [UsersRepository],

    repoFetchSubscription: undefined,

    subscribeToRepositories: function () {
      Producer.prototype.subscribeToRepositories.call(this);

      this.repoFetchSubscription = {
        pollingInterval: 1000 * 10,
        params: {}
      };

      UsersRepository.addSubscription(UsersRepository.ALL, this.repoFetchSubscription);
    },

    unsubscribeFromRepositories: function () {
      Producer.prototype.unsubscribeFromRepositories.call(this);
      UsersRepository.removeSubscription(UsersRepository.ALL, this.repoFetchSubscription);
    },

    currentData: function () {
      var loggedInUser = UsersRepository.getLoggedInUser();
      if (loggedInUser) {
        loggedInUser = loggedInUser.toJSON();
      }
      console.log('user: ', loggedInUser);
      return loggedInUser;
    }

  });

  return UserProfileProducer;

});
