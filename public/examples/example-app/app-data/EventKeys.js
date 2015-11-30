define(function (require) {
  'use strict';
  Vigor = require('vigor');

  Vigor.EventKeys.extend({
    COMPONENT_AREAS_ADDED: 'component-areas-added',
    ROUTE_CHANGE: 'route-change'
  });

  return Vigor.EventKeys;

});

