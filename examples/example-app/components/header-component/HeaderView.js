define(function (require) {

  'use strict';

  var HeaderView,
      $ = require('jquery'),
      Backbone = require('backbone'),
      headerTemplate = require('hbars!./templates/header-template');

  HeaderView = Backbone.View.extend({

    className: 'header-component',

    initialize: function () {
      this._renderDeferred = $.Deferred();
    },

    getRenderDonePromise: function () {
      return this._renderDeferred.promise();
    },

    render: function () {
      this.$el.html(headerTemplate());
      this._renderDeferred.resolve();
      return this;
    },

    dispose: function () {
      this.remove();
    }

  });

  return HeaderView;

});
