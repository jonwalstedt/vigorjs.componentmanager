define(function (require) {

  'use strict';

  var _parseUser = function (user) {
    return {
      id: user.id,
      firstName: user.first_name,
      lastName: user.last_name,
      account: user.account || 'free',
      bytesUsed: user.bytes_used || 0,
      profileImg: user.profile_img,
      loggedIn: user.logged_in || false
    }
  },

  UserParser = {
    parse: function (users) {
      for (var i = 0; i < users.length; i++) {
        users[i] = _parseUser(users[i]);
      };
      return users;
    }
  };

  return UserParser;

});
