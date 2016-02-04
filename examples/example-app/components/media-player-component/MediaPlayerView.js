define(function (require) {

  'use strict';

  var MediaPlayerView,
      $ = require('jquery'),
      ComponentViewBase = require('components/ComponentViewBase'),
      template = require('hbars!./templates/media-player-template');

  MediaPlayerView = ComponentViewBase.extend({

    className: 'media-player-component',

    initialize: function (options) {
      this.urlParamsCollection = options.urlParamsCollection;
      this.fileId = +this.urlParamsCollection.at(0).get('id');
      ComponentViewBase.prototype.initialize.apply(this, arguments);
      this.listenTo(this.viewModel.fileModel, 'change', _.bind(this.renderDynamicContent, this));
      this.listenTo(this.urlParamsCollection, 'change:id', _.bind(this._onIdChange, this));
    },

    renderStaticContent: function () {
      this.$el.html(template());
      this._renderDeferred.resolve();
      return this;
    },

    renderDynamicContent: function () {
      var fileJSON = this.viewModel.fileModel.toJSON(),
          artworkLargeSrc = fileJSON.artworkLarge,
          artworkLarge = new Image(),
          $artwork;

      this.$el.html(template(fileJSON));
      $artwork = $('.media-player__artwork', this.$el);

      artworkLarge.onload = function () {
        $artwork.attr('src', artworkLargeSrc);
        $artwork.addClass('media-player__artwork--loaded');
      };

      if (artworkLargeSrc) {
        artworkLarge.src = artworkLargeSrc;
      }

    },

    addSubscriptions: function () {
      this.viewModel.addSubscriptions(this.fileId);
    },

    removeSubscriptions: function () {
      this.viewModel.removeSubscriptions();
    },

    dispose: function () {
      ComponentViewBase.prototype.dispose.apply(this, null);
    },

    _onFileChange: function () {
      this.renderDynamicContent();
    },

    _onIdChange: function (model, id) {
      this.fileId = +id;
      this.removeSubscriptions();
      this.addSubscriptions();
    }

  });

  return MediaPlayerView;

});