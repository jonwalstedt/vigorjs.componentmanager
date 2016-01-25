define(function (require) {

  'use strict';

  var ComponentBase,
      $ = require('jquery'),
      Vigor = require('vigor');

  ComponentBase = Vigor.ComponentBase.extend({

    _renderDeferred: undefined,
    componentName: 'base-component',

    constructor: function (options) {
      this.initialize(options);
    },

    initialize: function (options) {
      this._renderDeferred = $.Deferred();
    },

    render: function () {
      this._renderDeferred.resolve();
      return this;
    },

    dispose: function () {
      // console.log('component disposed');
    },

    getRenderDonePromise: function () {
      return this._renderDeferred.promise();
    },

    // im a noop
    onPageReady: function () {}
  });

  return ComponentBase;

});
