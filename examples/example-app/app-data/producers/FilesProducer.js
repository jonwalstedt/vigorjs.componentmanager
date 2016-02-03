define(function (require) {

  'use strict';

  var FilesProducer,
      ProducerBase = require('./ProducerBase'),
      FilesRepository = require('repositories/files/FilesRepository'),
      MathUtil = require('utils/MathUtil'),
      subscriptionKeys = require('SubscriptionKeys');

  FilesProducer = ProducerBase.extend({

    PRODUCTION_KEY: subscriptionKeys.FILES,
    repositories: [FilesRepository],

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
    },

    currentData: function () {
      var files = FilesRepository.toJSON();
      for (var i = 0; i < files.length; i++) {
        files[i].fileSizeReadable = MathUtil.formatBytes(files[i].fileSize, 2).string;
      };
      return files.reverse();
    }

  });

  return FilesProducer;

});
