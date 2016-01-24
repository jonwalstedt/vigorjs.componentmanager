define(function (require) {

  'use strict';

  var UsersService,
      parser = require('./parsers/UserParser'),
      ServiceBase = require('./ServiceBase');

  UsersService = ServiceBase.extend({

    USERS_RECEIVED: 'users-received',
    urlPath: 'users',

    parse: function (users) {
      if (this._isGHPages) {
        users = users.users;
      }
      this.propagateResponse(this.USERS_RECEIVED, parser.parse(users));
    }

  });

  return new UsersService();
});
