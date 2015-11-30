define(function (require) {
  'use strict';

  var PageView,
      $ = require('jquery'),
      _ = require('underscore'),
      Backbone = require('backbone'),
      TweenMax = require('TweenMax');

  PageView = Backbone.View.extend({

    animationDuration: 0.5,
    animationDelay: 0.3,

    transitionPages: function (index, route) {
      var $current = $('.current-page', this.$el),
          $nextUp = $('.page:not(.current-page)', this.$el);

      if (index > 0) {
        this.scaleIn($nextUp, route);
        this.slideOut($current);

      } else if (index < 0) {
        this.scaleOut($current, 0.8);
        this.slideIn($nextUp, route);

      } else {
        this.scaleIn($nextUp, route);
        this.scaleOut($current, 2);
      }
    },

    // Page transitions
    // --------------------------------------------
    slideIn: function ($el, route) {
      $el.addClass('component-area--main page--on-top');

      TweenMax.fromTo($el, this.animationDuration, {
        xPercent: -100
      }, {
        delay: this.animationDelay,
        xPercent: 0,
        clearProps: 'xPercent',
        onComplete: function ($el, route) {
          $el.addClass('current-page');
          this.trigger('transition-complete', $el, route);
        },
        onCompleteParams: [$el, route],
        onCompleteScope: this
      });
    },

    scaleOut: function ($el, scaleTarget) {
      $el.removeClass('component-area--main page--on-top');
      TweenMax.fromTo($el, this.animationDuration, {
        scale: 1,
        opacity: 1
      }, {
        delay: this.animationDelay,
        scale: scaleTarget,
        opacity: 0,
        clearProps: 'opacity, scale',
        onComplete: function ($el) {
          $el.removeClass('current-page');
        },
        onCompleteParams: [$el]
      });
    },

    scaleIn: function ($el, route) {
      $el.addClass('component-area--main');

      TweenMax.fromTo($el, this.animationDuration, {
        opacity: 0,
        scale: .8
      }, {
        delay: this.animationDelay,
        opacity: 1,
        scale: 1,
        clearProps: 'opacity, scale',
        onComplete: function ($el, route) {
          $el.addClass('current-page page--on-top');
          this.trigger('transition-complete', $el, route);
        },
        onCompleteParams: [$el, route],
        onCompleteScope: this
      });
    },

    slideOut: function ($el) {
      $el.removeClass('component-area--main');
      TweenMax.fromTo($el, this.animationDuration, {
        xPercent: 0
      }, {
        delay: this.animationDelay,
        xPercent: -100,
        clearProps: 'xPercent',
        onComplete: function ($el) {
          $el.removeClass('current-page page--on-top');
        },
        onCompleteParams: [$el]
      });
    }

  });
  return PageView;
});
