define(function (require) {
  'use strict';

  var Preloader,
      $ = require('jquery'),
      _ = require('underscore'),
      Backbone = require('backbone'),
      preloaderTemplate = require('hbars!app/templates/preloader-template');

  Preloader = Backbone.View.extend({

    className: 'preloader preloader--visible',
    promises: [],
    promisesCompleteCount: 0,
    loadingDeferred: undefined,
    $preloaderTxt: undefined,
    $fill: undefined,

    initialize: function () {
      this.loadingDeferred = $.Deferred();
    },

    render: function () {
      this.$el.html(preloaderTemplate());
      this.$fill = $('.preloader__fill', this.$el);
      this.$preloaderTxt = $('.preloader__text', this.$el);
      return this;
    },

    preload: function (promises) {
      if (this.loadingDeferred.state() == 'resolved') {
        this.loadingDeferred = $.Deferred();
      }
      this.promisesCompleteCount = 0;
      this.promises = promises;
      for (var i = this.promises.length - 1; i >= 0; i--) {
        $.when(this.promises[i]).then(_.bind(this._updateProgressBar, this));
      };

      $.when.apply($, this.promises).then(_.bind(function () {
        this.loadingDeferred.resolve();
        this.trigger('loading-complete');
      }, this));

      return this.getLoadingPromise();
    },

    getLoadingPromise: function () {
      return this.loadingDeferred.promise();
    },

    _updateProgressBar: function () {
      var progress;
      this.promisesCompleteCount++;
      this.$preloaderTxt.text(this.promisesCompleteCount + '/' + this.promises.length + ' loaded');
      progress = (this.promisesCompleteCount / this.promises.length) * 100;
      this.$fill.css({width: progress + '%'});
    }

  });

  return Preloader;
});
