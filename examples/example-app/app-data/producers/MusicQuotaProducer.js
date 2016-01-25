define(function (require) {

  'use strict';

  var MusicQuotaProducer,
      BaseQuotaProducer = require('./BaseQuotaProducer'),
      UsersRepository = require('repositories/users/UsersRepository'),
      FilesRepository = require('repositories/files/FilesRepository'),
      subscriptionKeys = require('SubscriptionKeys');

  MusicQuotaProducer = BaseQuotaProducer.extend({

    PRODUCTION_KEY: subscriptionKeys.MUSIC_QUOTA,

    currentData: function () {
      return [{
        id: 'total',
        bytesUsed: UsersRepository.getLoggedInUser().bytesUsed,
        targetFileCount: FilesRepository.getCount()
      }, {
        id: 'music',
        bytesUsed: FilesRepository.getBytesUsedByMusic(),
        targetFileCount: FilesRepository.getCountByFileType('music')
      }];
    }

  });

  return MusicQuotaProducer;

});
