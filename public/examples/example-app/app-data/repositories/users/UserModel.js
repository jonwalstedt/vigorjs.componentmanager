define(function (require) {

  'use strict';

  var UserModel,
      Backbone = require('backbone');

  UserModel = Backbone.Model.extend({
    defaults: {
      id: undefined,
      first_name: undefined,
      last_name: undefined,
      accout: undefined,
      bytes_used: undefined,
      profile_img: undefined,
      logged_in: false
    }
  });

  return UserModel;

});
