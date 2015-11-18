define(function (require) {

  'use strict';

  var BannerComponent,
      IframeComponent = require('vigor').IframeComponent

  BannerComponent = IframeComponent.extend({

    _renderDeferred: undefined,
    componentName: 'banner-component',

    initialize: function (args) {
      console.log('BannerComponent initialized');
      this._renderDeferred = $.Deferred();
      IframeComponent.prototype.initialize.apply(this, arguments);
    },

    dispose: function () {
      console.log('Banner disposed');
      IframeComponent.prototype.dispose.apply(this, arguments);
    },

    getRenderDonePromise: function () {
      return this._renderDeferred.promise();
    },

    receiveMessage: function (message) {
      if (message == 'loading-complete') {
        this._renderDeferred.resolve();
      }
    },

    // im a noop
    onIframeLoaded: function (event) {},

    // im a noop
    onPageReady: function () {}
  });

  return BannerComponent;

});
