define(function (require) {
  'use strict';

  Vigor = require('vigor');

  Vigor.SubscriptionKeys.extend({
    ARTICLES: {
      key: 'articles',
      contract: []
    },

    FILTER: {
      key: 'filter',
      contract: []
    }

  });

  return Vigor.SubscriptionKeys;

});

