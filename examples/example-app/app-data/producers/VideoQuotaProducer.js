define(function (require) {

  'use strict';

  var VideoQuotaProducer,
      QuotaProducerBase = require('./QuotaProducerBase'),
      UsersRepository = require('repositories/users/UsersRepository'),
      FilesRepository = require('repositories/files/FilesRepository'),
      subscriptionKeys = require('SubscriptionKeys');

  VideoQuotaProducer = QuotaProducerBase.extend({

    PRODUCTION_KEY: subscriptionKeys.VIDEO_QUOTA,

    currentData: function () {
      return [{
        id: 'total',
        bytesUsed: UsersRepository.getLoggedInUser().bytesUsed,
        targetFileCount: FilesRepository.getCount()
      }, {
        id: 'videos',
        bytesUsed: FilesRepository.getBytesUsedByVideos(),
        targetFileCount: FilesRepository.getCountByFileType('video')
      }];
    }

  });

  return VideoQuotaProducer;

});
