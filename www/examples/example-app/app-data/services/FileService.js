define(function (require) {

  'use strict';

  var UserService,
      parser = require('./parsers/FileParser'),
      ServiceBase = require('./ServiceBase');

  UserService = ServiceBase.extend({

    FILES_RECEIVED: 'files-received',
    urlPath: 'files',

    parse: function (files) {
      if (this._isGHPages) {
        files = files.files;
      }
      this.propagateResponse(this.FILES_RECEIVED, parser.parse(files));
    }

  });

  return new UserService();
});