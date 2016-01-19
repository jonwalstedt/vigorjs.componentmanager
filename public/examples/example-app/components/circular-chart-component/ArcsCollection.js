define(function (require) {

  'use strict';

  var ArcsCollection,
      ArcModel = require('./ArcModel'),
      Backbone = require('backbone');

  ArcsCollection = Backbone.Collection.extend({
    model: ArcModel
 })

  return ArcsCollection;
});
