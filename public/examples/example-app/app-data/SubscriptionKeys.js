define(function (require) {
  'use strict';

  Vigor = require('vigor');

  Vigor.SubscriptionKeys.extend({

    USER_PROFILE: {
      key: 'user-profile',
      contract: []
    }

  });

  return Vigor.SubscriptionKeys;

});

