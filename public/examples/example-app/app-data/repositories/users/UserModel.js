define(function (require) {

  'use strict';

  var UserModel,
      Backbone = require('backbone');

  UserModel = Backbone.Model.extend({
    defaults: {
      id: undefined,
      firstName: undefined,
      lastName: undefined,
      account: 'free',
      bytesUsed: 0,
      profileImg: undefined,
      loggedIn: false
    }
  });

  return UserModel;

});
