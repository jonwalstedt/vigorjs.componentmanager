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
    $preloaderTxt: undefined,
    $fill: undefined,

    render: function () {
      this.$el.html(preloaderTemplate());
      this.$fill = $('.preloader__fill', this.$el);
      this.$preloaderTxt = $('.preloader__text', this.$el);
      return this;
    },

    preload: function (promises) {
      this.promisesCompleteCount = 0;
      this.promises = promises;
      for (var i = this.promises.length - 1; i >= 0; i--) {
        $.when(this.promises[i]).then(_.bind(this.updateProgressBar, this));
      };

      $.when.apply($, this.promises).then(_.bind(function () {
        setTimeout(_.bind (function () {
          this.trigger('loading-complete');
        }, this), 400);
      }, this));
    },

    updateProgressBar: function () {
      var progress;
      this.promisesCompleteCount++;
      this.$preloaderTxt.text(this.promisesCompleteCount + '/' + this.promises.length + ' loaded');
      progress = (this.promisesCompleteCount / this.promises.length) * 100;
      this.$fill.css({width: progress + '%'});
    }

  });

  return Preloader;
});
