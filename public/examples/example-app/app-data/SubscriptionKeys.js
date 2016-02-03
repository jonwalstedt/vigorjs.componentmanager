define(function (require) {
  'use strict';

  Vigor = require('vigor');

  Vigor.SubscriptionKeys.extend({

    USER_PROFILE: {
      key: 'user-profile',
      contract: {
        id: undefined,
        firstName: undefined,
        lastName: undefined,
        account: undefined,
        bytesUsed: undefined,
        profileImg: undefined,
        loggedIn: false,
        usedPercentage: undefined,
        usedFormatted: undefined,
        limitFormatted: undefined
      }
    },

    MUSIC_QUOTA: {
      key: 'music-quota',
      contract: []
    },

    VIDEO_QUOTA: {
      key: 'video-quota',
      contract: []
    },

    PHOTO_QUOTA: {
      key: 'photo-quota',
      contract: []
    },

    DAILY_USAGE: {
      key: 'daily-usage',
      contract: {
        labels: [],
        datasets: []
      }
    },

    FILES: {
      key: 'files',
      contract: []
    },

    FILE: {
      key: 'file',
      contract: {}
    }
  });

  return Vigor.SubscriptionKeys;

});

