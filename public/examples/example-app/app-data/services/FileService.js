define(function (require) {

  'use strict';

  var UserService,
      parser = require('./parsers/FileParser'),
      ServiceBase = require('./ServiceBase');

  UserService = ServiceBase.extend({

    FILES_RECEIVED: 'files-received',

    parse: function (files) {
      this.propagateResponse(this.FILES_RECEIVED, parser.parse(files));
    },

    urlPath: function (model) {
      return 'files';
    }

  });

  return new UserService();
});