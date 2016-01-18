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
    }

  });

  return Vigor.SubscriptionKeys;

});

