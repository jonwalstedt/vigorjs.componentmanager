define(function (require) {

  'use strict';

  var FilterModel,
      Backbone = require('backbone');

  FilterModel = Backbone.Model.extend({
    defaults: {
      id: undefined,
      type: undefined,
      value: undefined
    }
  });

  return FilterModel;

});
