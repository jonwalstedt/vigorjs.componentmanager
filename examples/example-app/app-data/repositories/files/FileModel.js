define(function (require) {

  'use strict';

  var FileModel,
      Backbone = require('backbone');

  FileModel = Backbone.Model.extend({
    defaults: {
      id: undefined,
      name: undefined,
      desc: undefined,
      year: undefined,
      artworkLarge: undefined,
      artworkSmall: undefined,
      fileType: undefined,
      fileSize: undefined,
      uploaded: undefined
    }
  });

  return FileModel;

});
