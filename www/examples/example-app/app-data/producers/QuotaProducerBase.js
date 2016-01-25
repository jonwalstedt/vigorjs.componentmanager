define(function (require) {

  'use strict';

  var BaseQuotaProducer,
      ProducerBase = require('./ProducerBase'),
      ArcDecorator = require('./decorators/ArcDecorator'),
      UsersRepository = require('repositories/users/UsersRepository'),
      FilesRepository = require('repositories/files/FilesRepository'),
      subscriptionKeys = require('SubscriptionKeys');

  BaseQuotaProducer = ProducerBase.extend({

    repositories: [UsersRepository, FilesRepository],
    decorators: [ArcDecorator],

    repoFetchSubscription: undefined,

    subscribeToRepositories: function () {
      ProducerBase.prototype.subscribeToRepositories.call(this);

      this.repoFetchSubscription = {
        pollingInterval: 1000 * 10,
        params: {}
      };

      FilesRepository.addSubscription(FilesRepository.ALL, this.repoFetchSubscription);
    },

    unsubscribeFromRepositories: function () {
      ProducerBase.prototype.unsubscribeFromRepositories.call(this);
      FilesRepository.removeSubscription(FilesRepository.ALL, this.repoFetchSubscription);
    }

  });

  return BaseQuotaProducer;

});
