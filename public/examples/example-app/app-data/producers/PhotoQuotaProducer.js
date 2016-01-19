define(function (require) {

  'use strict';

  var PhotoQuotaProducer,
      BaseQuotaProducer = require('./BaseQuotaProducer'),
      UsersRepository = require('repositories/users/UsersRepository'),
      FilesRepository = require('repositories/files/FilesRepository'),
      subscriptionKeys = require('SubscriptionKeys');

  PhotoQuotaProducer = BaseQuotaProducer.extend({

    PRODUCTION_KEY: subscriptionKeys.PHOTO_QUOTA,

    currentData: function () {
      return [{
        id: 'total',
        bytesUsed: UsersRepository.getLoggedInUser().bytesUsed
      }, {
        id: 'photos',
        bytesUsed: FilesRepository.getBytesUsedByPhotos()
      }];
    }

  });

  return PhotoQuotaProducer;

});
