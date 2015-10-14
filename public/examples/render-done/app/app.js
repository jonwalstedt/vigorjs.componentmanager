var app = app || {};

(function ($) {
  'use strict';

  app.Filter = Backbone.View.extend({

    preloader: undefined,
    router: undefined,
    duration: 0.5,

    events: {
      'click .start-example-btn': 'startApplication',
      'click .menu-toggle': 'onMenuToggleClick'
    },

    $overlay: undefined,
    $contentWrapper: undefined,

    initialize: function () {
      this.$overlay = $('.overlay', this.$el);
      this.$contentWrapper = $('.content-wrapper', this.$el);

      Vigor.componentManager.initialize(window.componentSettings);
      this.showOverlay();
      this.router = new app.Router();
      app.filterModel.on('change', _.bind(this.onFilterChange, this));
      this.router.on('route-change', _.bind(this.onRouteChange, this));
    },

    addPreloader: function () {
      this.preloader = new app.Preloader();
      this.preloader.on('loading-complete', _.bind(this.onLoadingComplete, this));
      this.$overlay.html(this.preloader.render().$el);
    },

    startApplication: function () {
      Backbone.history.start({root: '/examples/render-done/'});
    },

    openMenu: function () {
      this.$el.addClass('menu-visible');
    },

    closeMenu: function () {
      this.$el.removeClass('menu-visible');
    },

    showOverlay: function () {
      this.$overlay.addClass('overlay--visible');
    },

    hideOverlay: function () {
      this.$overlay.removeClass('overlay--visible');
    },

    // Page transitions
    // --------------------------------------------
    slideIn: function ($el, route) {
      $el.addClass('component-area--main');

      // Trigger filter change that will add components to the next page
      // whitout removing the old ones
      _.defer(function () {
        app.filterModel.set({url: route, options: {remove: false}});
      });

      $el.addClass('page--on-top');
      TweenMax.fromTo($el, this.duration, {
        xPercent: -100,
      }, {
        xPercent: 0,
        clearProps: 'xPercent',
        onComplete: function ($el, route) {
          $el.addClass('current-page');
          // Trigger the same filter again but with remove set to true
          // this will not recreate existing instances but only remove
          // the components that no longer matches the filter
          app.filterModel.set({url: route, options: {remove: true}});
        },
        onCompleteParams: [$el, route]
      });
    },

    scaleOut: function ($el, scaleTarget) {
      $el.removeClass('component-area--main page--on-top');
      TweenMax.fromTo($el, this.duration, {
        scale: 1,
        opacity: 1
      }, {
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

      // Trigger filter change that will add components to the next page
      // whitout removing the old ones
      _.defer(function () {
        app.filterModel.set({url: route, options: {remove: false}});
      });

      TweenMax.fromTo($el, this.duration, {
        opacity: 0,
        scale: .8
      }, {
        opacity: 1,
        scale: 1,
        clearProps: 'opacity, scale',
        onComplete: function ($el, route) {
          $el.addClass('current-page page--on-top');
          // Trigger the same filter again but with remove set to true
          // this will not recreate existing instances but only remove
          // the components that no longer matches the filter
          app.filterModel.set({url: route, options: {remove: true}});
        },
        onCompleteParams: [$el, route]
      });
    },

    slideOut: function ($el) {
      $el.removeClass('component-area--main');
      TweenMax.fromTo($el, this.duration, {
        xPercent: 0
      }, {
        xPercent: -100,
        clearProps: 'xPercent',
        onComplete: function ($el) {
          $el.removeClass('current-page page--on-top');
        },
        onCompleteParams: [$el]
      });
    },

    // Callbacks
    // --------------------------------------------
    onRouteChange: function (routeInfo) {
      var index = routeInfo.index,
          $current = $('.current-page', this.$el),
          $nextUp = $('.page:not(.current-page)', this.$el);

      console.log('index: ', index);
      if (index > 0) {
        console.log('slide out scale in');
        this.scaleIn($nextUp, routeInfo.route);
        this.slideOut($current);

      } else if (index < 0) {
        console.log('scale out slide in');
        this.scaleOut($current, 0.8);
        this.slideIn($nextUp, routeInfo.route);

      } else {
        console.log('scale in scale out');
        this.scaleIn($nextUp, routeInfo.route);
        this.scaleOut($current, 2);
      }

      this.closeMenu();
    },

    onMenuToggleClick: function () {
      if (this.$el.hasClass('menu-visible')) {
        this.closeMenu();
      } else {
        this.openMenu();
      }
    },

    onLoadingComplete: function () {
      this.preloader.remove();
      this.hideOverlay();
      TweenMax.staggerFromTo($('.vigor-component'), 4, {autoAlpha: 0}, {autoAlpha: 1, position: 'relative'}, 0.2);
    },

    onFilterChange: function () {
      console.log('onFilterChange: ', app.filterModel.toJSON());
      // Vigor.componentManager.refresh(app.filterModel.toJSON());
      var promises = [],
          filter = app.filterModel.toJSON();

      Vigor.componentManager.refresh(filter, _.bind(function (filter, activeInstances) {
        for (var i = activeInstances.length - 1; i >= 0; i--) {
          promises.push(activeInstances[i].getRenderDonePromise());
        };
      }, this));

      this.addPreloader();
      this.preloader.preload(promises);
    }

  });

})(jQuery);
