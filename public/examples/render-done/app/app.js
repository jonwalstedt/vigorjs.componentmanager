var app = app || {};

(function ($) {
  'use strict';

  app.Filter = Backbone.View.extend({

    promises: undefined,
    promisesCompleteCount: 0,
    $fill: undefined,
    $preloader: undefined,
    $preloaderTxt: undefined,

    events: {
      'click .start-example-btn': 'startApplication'
    },

    initialize: function () {
      this.promises = [];
      this.$fill = $('.preloader__fill', this.$el);
      this.$preloader = $('.preloader', this.$el);
      this.$preloaderTxt = $('.preloader__text', this.$el);

      Vigor.componentManager.initialize(window.componentSettings);

    },

    startApplication: function () {
      Vigor.componentManager.refresh(null, _.bind(function (filter, activeInstances) {
        for (var i = activeInstances.length - 1; i >= 0; i--) {
          this.promises.push(activeInstances[i].getRenderDonePromise());
        };
      }, this));

      for (var i = this.promises.length - 1; i >= 0; i--) {
        $.when(this.promises[i]).then(_.bind(this.updateProgressBar, this));
      };

      $.when.apply($, this.promises).then(_.bind(function () {

        setTimeout(_.bind (function () {
          this.$preloader.remove();
          this.loadingComplete();
        }, this), 400);

      }, this));

      this.$preloader.addClass('preloader--visible');
    },

    updateProgressBar: function () {
      var progress;
      this.promisesCompleteCount++;
      this.$preloaderTxt.text(this.promisesCompleteCount + '/' + this.promises.length + ' loaded');
      progress = (this.promisesCompleteCount / this.promises.length) * 100;
      this.$fill.css({width: progress + '%'});
    },

    loadingComplete: function () {
      console.log('loadingComplete');
      TweenMax.staggerFromTo($('.vigor-component'), 4, {autoAlpha: 0}, {autoAlpha: 1, position: 'relative'}, 0.2);
    }

});

})(jQuery);
