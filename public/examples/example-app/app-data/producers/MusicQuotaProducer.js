define(function (require) {

  'use strict';

  var MusicQuotaProducer,
      MathUtil = require('utils/MathUtil'),
      BaseProducer = require('./BaseProducer'),
      AccountTypes = require('app/AccountTypes'),
      UsersRepository = require('repositories/users/UsersRepository'),
      FilesRepository = require('repositories/files/FilesRepository'),
      subscriptionKeys = require('SubscriptionKeys');

  MusicQuotaProducer = BaseProducer.extend({

    PRODUCTION_KEY: subscriptionKeys.MUSIC_QUOTA,
    repositories: [UsersRepository, FilesRepository],

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
    },

    currentData: function () {
      var user = UsersRepository.getLoggedInUser(),
          bytesUsedByMusic = FilesRepository.getBytesUsedByMusic(),
          limit = AccountTypes[user.account].bytesLimit,
          formattedLimit = MathUtil.formatBytes(limit, 2),

          formattedUsedByMusic = MathUtil.formatBytes(bytesUsedByMusic, 2),
          usedByMusic = formattedUsedByMusic.value,
          usedByMusicSuffix = formattedUsedByMusic.suffix,

          formattedUsedBytes = MathUtil.formatBytes(user.bytesUsed, 2),
          usedTotal = formattedUsedBytes.value,
          usedTotalSuffix = formattedUsedBytes.suffix,

          musicQuota = +((bytesUsedByMusic / limit) * 100).toFixed(2),
          totalQuota = +((user.bytesUsed / limit) * 100).toFixed(2);

      var vals = [{
        id: 'total',
        // percent: totalQuota,
        percent: Math.random()*100, //totalQuota,
        used: Math.random()*100, //usedTotal,
        usedSuffix: usedTotalSuffix,
        limit: formattedLimit.value,
        limitSuffix: formattedLimit.suffix
      },
      {
        id: 'music',
        percent: Math.random()*100, //musicQuota,
        used: Math.random()*100, //usedByMusic,
        usedSuffix: usedByMusicSuffix,
        limit: formattedLimit.value,
        limitSuffix: formattedLimit.suffix
      }];
      return vals;
    }

  });

  return MusicQuotaProducer;

});
