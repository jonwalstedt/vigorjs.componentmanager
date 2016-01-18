define(function (require) {

  'use strict';

  var UsersService,
      parser = require('./parsers/UserParser'),
      ServiceBase = require('./ServiceBase');

  UsersService = ServiceBase.extend({

    USERS_RECEIVED: 'users-received',

    parse: function (users) {
      this.propagateResponse(this.USERS_RECEIVED, parser.parse(users));
    },

    urlPath: function (model) {
      return 'users';
    }

  });

  return new UsersService();
});
