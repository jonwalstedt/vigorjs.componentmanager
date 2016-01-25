define(function (require) {
  'use strict';

  Vigor = require('vigor');

  Vigor.SubscriptionKeys.extend({

    USER_PROFILE: {
      key: 'user-profile',
      contract: {
        id: undefined,
        first_name: undefined,
        last_name: undefined,
        account: undefined,
        bytes_used: undefined,
        profile_img: undefined,
        logged_in: false
      }
    },

    MUSIC_QUOTA: {
      key: 'music-quota',
      contract: {}
    },

    VIDEO_QUOTA: {
      key: 'video-quota',
      contract: {}
    },

    PHOTO_QUOTA: {
      key: 'photo-quota',
      contract: {}
    },

    DAILY_USAGE: {
      key: 'daily-usage',
      contract: {}
    }
  });

  return Vigor.SubscriptionKeys;

});

