define(function (require) {
  'use strict';

  Vigor = require('vigor');

  Vigor.SubscriptionKeys.extend({
    PROJECT: {
      key: 'project',
      contract: {}
    },

    PROJECTS: {
      key: 'projects',
      contract: []
    }
  });

  return Vigor.SubscriptionKeys;

});

