define(function (require) {

  'use strict';

  var MiniProfileView,
      $ = require('jquery'),
      ComponentViewBase = require('components/ComponentViewBase'),
      template = require('hbars!./templates/mini-profile-template');

  MiniProfileView = ComponentViewBase.extend({

    className: 'mini-profile-component',
    $profilePicture: undefined,
    $profileUserName: undefined,
    $graphHeader: undefined,
    $graphBar: undefined,

    initialize: function (options) {
      ComponentViewBase.prototype.initialize.apply(this, arguments);
      this.viewModel.userModel.on('change:profileImg', _.bind(this._onProfilePictureChange, this));
      this.viewModel.userModel.on('change:firstName', _.bind(this._onProfileNameChange, this));
      this.viewModel.userModel.on('change:lastName', _.bind(this._onProfileNameChange, this));
      this.viewModel.userModel.on('change:bytesUsed', _.bind(this._onBytesUsedChange, this));
    },

    renderStaticContent: function () {
      this.$el.html(template());
      this.$profilePicture = $('.mini-profile__profile-picture', this.$el);
      this.$profileUserName = $('.mini-profile__user-name', this.$el);
      this.$graphHeader = $('.mini-profile__stats-header', this.$el);
      this.$graphBar = $('.mini-profile__stats-bar', this.$el);
      return this;
    },

    renderDynamicContent: function () {},

    addSubscriptions: function () {
      this.viewModel.addSubscriptions();
    },

    removeSubscriptions: function () {
      this.viewModel.removeSubscriptions();
    },

    dispose: function () {
      this.viewModel.userModel.off();
      this.$profilePicture = undefined;
      this.$profileUserName = undefined;
      this.$graphHeader = undefined;
      this.$graphBar = undefined;
      ComponentViewBase.prototype.dispose.apply(this, null);
    },

    _onProfileNameChange: function () {
      var userName = this.viewModel.userModel.get('firstName') + ' ' + this.viewModel.userModel.get('lastName');
      this.$profileUserName.html(userName);
    },

    _onProfilePictureChange: function () {
      var profilePicture = new Image();
      profilePicture.onload = _.bind(function () {
        this._renderDeferred.resolve();
      }, this);
      profilePicture.src = this.viewModel.userModel.get('profileImg');
      profilePicture.className = 'mini-profile__image';
      profilePicture.width = 100;
      profilePicture.height = 100;
      this.$profilePicture.html(profilePicture);
    },

    _onBytesUsedChange: function () {
      var used = this.viewModel.userModel.get('bytesUsed'),
          usedPercentage = this.viewModel.userModel.get('usedPercentage'),
          usedFormatted = this.viewModel.userModel.get('usedFormatted'),
          limitFormatted = this.viewModel.userModel.get('limitFormatted');

      this.$graphHeader.html(usedFormatted + ' of ' + limitFormatted + ' used');
      this.$graphBar.css('width', usedPercentage + '%');
    }
  });

  return MiniProfileView;

});