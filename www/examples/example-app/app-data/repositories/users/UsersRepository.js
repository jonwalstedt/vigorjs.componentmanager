define(function (require) {

  'use strict';

  var UsersRepository,
      UserModel = require('./UserModel'),
      ServiceRepository = require('vigor').ServiceRepository,
      UsersService = require('services/UsersService');

  UsersRepository = ServiceRepository.extend({

    ALL: 'all',
    services: {
      'all': UsersService,
    },

    model: UserModel,

    initialize: function () {
      UsersService.on(UsersService.USERS_RECEIVED, _.bind(this._onUsersReceived, this));
      ServiceRepository.prototype.initialize.call(this, arguments);
    },

    getLoggedInUser: function () {
      var user = this.findWhere({loggedIn: true});

      if (user)
        user = user.toJSON()
      else
        user = UserModel.prototype.defaults;

      return user;
    },

    _onUsersReceived: function (users) {
      this.set(users);
    }
  });

  return new UsersRepository();

});
