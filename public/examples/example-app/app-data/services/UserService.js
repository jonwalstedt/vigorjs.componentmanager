define(function (require) {

  'use strict';

  var UserService,
      EventKeys = require('EventKeys'),
      APIService = require('vigor').APIService;

  UserService = APIService.extend({

    USER_RECEIVED: 'user-received',

    parse: function (user) {
      this.propagateResponse(this.USER_RECEIVED, user);
    },

    url: function (model) {
      return 'http://localhost:4000/users';
    }

  });

  return new UserService();
});
