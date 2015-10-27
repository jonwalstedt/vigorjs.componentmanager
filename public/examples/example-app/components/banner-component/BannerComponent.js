var app = app || {};
app.components = app.components || {};

app.components.BannerComponent = Vigor.IframeComponent.extend({

  _renderDeferred: undefined,
  componentName: 'banner-component',

  initialize: function (args) {
    console.log('BannerComponent initialized');
    this._renderDeferred = $.Deferred();
    Vigor.IframeComponent.prototype.initialize.apply(this, arguments);
  },

  onIframeLoaded: function (event) {},

  dispose: function () {
    console.log('Banner disposed');
    Vigor.IframeComponent.prototype.dispose.apply(this, arguments);
  },

  getRenderDonePromise: function () {
    return this._renderDeferred.promise();
  },

  receiveMessage: function (message) {
    if (message == 'loading-complete') {
      this._renderDeferred.resolve();
    }
  },

  onPageReady: function () {
    // im a noop
  }
});
