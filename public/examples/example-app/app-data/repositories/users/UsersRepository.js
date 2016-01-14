define(function (require) {

  'use strict';

  var UsersRepository,
      UserModel = require('./UserModel'),
      ServiceRepository = require('vigor').ServiceRepository,
      UsersService = require('services/UserService');

  UsersRepository = ServiceRepository.extend({

    ALL: 'all',
    services: {
      'all': UsersService,
    },

    model: UserModel,

    initialize: function () {
      UsersService.on(UsersService.USER_RECEIVED, _.bind(this._onUsersReceived, this));
      ServiceRepository.prototype.initialize.call(this, arguments);
    },

    getLoggedInUser: function () {
      return this.findWhere({logged_in: true});
    },

    _onUsersReceived: function (user) {
      this.set(user);
    }
  });

  return new UsersRepository();

});
