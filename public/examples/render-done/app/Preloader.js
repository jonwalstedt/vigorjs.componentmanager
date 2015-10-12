var app = app || {};

(function ($) {
  'use strict';

  app.Preloader = Backbone.View.extend({

    template: _.template($('script.preloader-template').html()),
    className: 'preloader preloader--visible',
    promises: [],
    promisesCompleteCount: 0,
    $preloaderTxt: undefined,
    $fill: undefined,

    render: function () {
      this.$el.html(this.template());
      this.$fill = $('.preloader__fill', this.$el);
      this.$preloaderTxt = $('.preloader__text', this.$el);
      return this;
    },

    preload: function (promises) {
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

})(jQuery);
