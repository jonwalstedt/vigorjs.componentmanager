define(function (require) {

  'use strict';

  var SectionCollection,
      SectionModel = require('./SectionModel'),
      Backbone = require('backbone');

  SectionCollection = Backbone.Collection.extend({
    model: SectionModel
  });

  return SectionCollection;

});