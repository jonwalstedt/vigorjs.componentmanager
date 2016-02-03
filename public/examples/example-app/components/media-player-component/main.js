define(function (require) {

  'use strict';

  var MediaPlayer,
      ComponentBase = require('components/ComponentBase'),
      MediaPlayerView = require('./MediaPlayerView'),
      MediaPlayerViewModel = require('./MediaPlayerViewModel');

  MediaPlayer = ComponentBase.extend({

    $el: undefined,
    _mediaPlayerViewModel: undefined,
    _mediaPlayerView: undefined,

    constructor: function (options) {
      console.log('MediaPlayer initialized');
      this._mediaPlayerViewModel = new MediaPlayerViewModel({subscriptionKey: options.subscriptionKey});
      options.viewModel = this._mediaPlayerViewModel;

      this._mediaPlayerView = new MediaPlayerView(options);
      this.$el = this._mediaPlayerView.$el;
      $.when(this._mediaPlayerView.getRenderDonePromise()).then(_.bind(this._resolvePromise, this));
      ComponentBase.prototype.constructor.apply(this, arguments);
    },

    render: function () {
      this._mediaPlayerView.render();
      return this;
    },

    dispose: function () {
      console.log('MediaPlayer disposed');
      this._mediaPlayerView.dispose();
      this._mediaPlayerViewModel.dispose();
      this._mediaPlayerView = undefined;
      this._mediaPlayerViewModel = undefined;
      this.$el.remove();
      this.$el = undefined;
    },

    _resolvePromise: function () {
      this._renderDeferred.resolve();
    }
  });

  return MediaPlayer;

});
