define(function (require) {

  'use strict';

  var ArcsModel,
      Backbone = require('backbone');

  ArcsModel = Backbone.Model.extend({
    defaults: {
      id: undefined,
      percent: 0,
      targetPercent: 0,
      used: 0,
      targetUsed: 0,
      usedSuffix: 'Bytes',
      angle: 0,
      targetAngle: 0,
      limit: 0,
      limitSuffix: 'Bytes'
    }
  })

  return ArcsModel;
});
