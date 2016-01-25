define(function (require) {

  'use strict';

  var PhotoQuotaProducer,
      QuotaProducerBase = require('./QuotaProducerBase'),
      UsersRepository = require('repositories/users/UsersRepository'),
      FilesRepository = require('repositories/files/FilesRepository'),
      subscriptionKeys = require('SubscriptionKeys');

  PhotoQuotaProducer = QuotaProducerBase.extend({

    PRODUCTION_KEY: subscriptionKeys.PHOTO_QUOTA,

    currentData: function () {
      return [{
        id: 'total',
        bytesUsed: UsersRepository.getLoggedInUser().bytesUsed,
        targetFileCount: FilesRepository.getCount()
      }, {
        id: 'photos',
        bytesUsed: FilesRepository.getBytesUsedByPhotos(),
        targetFileCount: FilesRepository.getCountByFileType('photo')
      }];
    }

  });

  return PhotoQuotaProducer;

});
