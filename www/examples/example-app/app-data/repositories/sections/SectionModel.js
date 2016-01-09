define(function (require) {

  'use strict';

  var SectionModel,
      Backbone = require('backbone');

  SectionModel = Backbone.Model.extend({
    defaults: {
      id: undefined,
      display_name: undefined,
      section: undefined
    }
  });

  return SectionModel;

});
