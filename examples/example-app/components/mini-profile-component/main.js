define(function (require) {

  'use strict';

  var MiniProfile,
      $ = require('jquery'),
      _ = require('underscore'),
      ComponentBase = require('components/ComponentBase'),
      MiniProfileView = require('./MiniProfileView'),
      MiniProfileViewModel = require('./MiniProfileViewModel');

  MiniProfile = ComponentBase.extend({

    $el: undefined,
    _miniProfileViewModel: undefined,
    _miniProfileView: undefined,

    constructor: function (options) {
      console.log('MiniProfile initialized');
      this._miniProfileViewModel = new MiniProfileViewModel();
      this._miniProfileView = new MiniProfileView({viewModel: this._miniProfileViewModel});
      this.$el = this._miniProfileView.$el;
      $.when(this._miniProfileView.getRenderDonePromise()).then(_.bind(this._resolvePromise, this));
      ComponentBase.prototype.constructor.apply(this, arguments);
    },

    render: function () {
      this._miniProfileView.render();
      return this;
    },

    dispose: function () {
      console.log('MiniProfile disposed');
      this._miniProfileView.dispose();
      this._miniProfileViewModel.dispose();
      this._miniProfileView = undefined;
      this._miniProfileViewModel = undefined;
      this.$el.remove();
      this.$el = undefined;
    },

    _resolvePromise: function () {
      this._renderDeferred.resolve();
    }
  });

  return MiniProfile;

});
