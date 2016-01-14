define(function (require) {

  'use strict';

  var MiniProfileView,
      $ = require('jquery'),
      AccountTypes = require('app/AccountTypes'),
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
      this.viewModel.userModel.on('change:profile_img', _.bind(this._onProfilePictureChange, this));
      this.viewModel.userModel.on('change:first_name', _.bind(this._onProfileNameChange, this));
      this.viewModel.userModel.on('change:last_name', _.bind(this._onProfileNameChange, this));
      this.viewModel.userModel.on('change:bytes_used', _.bind(this._onBytesUsedChange, this));
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
      ComponentViewBase.prototype.dispose.apply(this, null);
    },

    _onProfileNameChange: function () {
      var userName = this.viewModel.userModel.get('first_name') + ' ' + this.viewModel.userModel.get('last_name');
      this.$profileUserName.html(userName);
    },

    _onProfilePictureChange: function () {
      var profilePicture = new Image();
      profilePicture.onload = _.bind(function () {
        console.log('onsuccess');
        this._renderDeferred.resolve();
      }, this);
      profilePicture.src = this.viewModel.userModel.get('profile_img');
      profilePicture.className = 'mini-profile__image';
      profilePicture.width = 100;
      profilePicture.height = 100;
      this.$profilePicture.html(profilePicture);
    },

    _onBytesUsedChange: function () {
      var used = this.viewModel.userModel.get('bytes_used'),
          limit = AccountTypes.premium.bytesLimit,
          usedFormatted = this._formatBytes(used, 2),
          limitFormatted = this._formatBytes(limit, 2),
          usedPercentage = (used / limit) * 100;

      this.$graphHeader.html(usedFormatted + ' of ' + limitFormatted + ' used');
      this.$graphBar.css('width', usedPercentage + '%');
    },

    _formatBytes: function (bytes, decimals) {
      var k = 1000,
          dm = decimals + 1 || 3,
          sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'],
          i = Math.floor(Math.log(bytes) / Math.log(k));

      if (bytes == 0) return '0 Byte';
      return (bytes / Math.pow(k, i)).toPrecision(dm) + ' ' + sizes[i];
    }

  });

  return MiniProfileView;

});