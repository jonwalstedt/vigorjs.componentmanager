define(function (require) {

  'use strict';

  var BaseQuotaProducer,
      BaseProducer = require('./BaseProducer'),
      ArcDecorator = require('./decorators/ArcDecorator'),
      UsersRepository = require('repositories/users/UsersRepository'),
      FilesRepository = require('repositories/files/FilesRepository'),
      subscriptionKeys = require('SubscriptionKeys');

  BaseQuotaProducer = BaseProducer.extend({

    repositories: [UsersRepository, FilesRepository],
    decorators: [ArcDecorator],

    repoFetchSubscription: undefined,

    subscribeToRepositories: function () {
      BaseProducer.prototype.subscribeToRepositories.call(this);

      this.repoFetchSubscription = {
        pollingInterval: 1000 * 10,
        params: {}
      };

      FilesRepository.addSubscription(FilesRepository.ALL, this.repoFetchSubscription);
    },

    unsubscribeFromRepositories: function () {
      BaseProducer.prototype.unsubscribeFromRepositories.call(this);
      FilesRepository.removeSubscription(FilesRepository.ALL, this.repoFetchSubscription);
    }

  });

  return BaseQuotaProducer;

});
