var app = app || {};

(function ($) {
  'use strict';

  app.Filter = Backbone.View.extend({

    preloader: undefined,
    router: undefined,

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
      var promises = [];
      Vigor.componentManager.refresh({url: Backbone.history.fragment}, _.bind(function (filter, activeInstances) {
        for (var i = activeInstances.length - 1; i >= 0; i--) {
          promises.push(activeInstances[i].getRenderDonePromise());
        };
      }, this));

      this.addPreloader();
      this.preloader.preload(promises);
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
    },

    onRouteChange: function (routeInfo) {
      var nrOfSlides = $('.content__slide').length,
          widthInPercent = 100 / nrOfSlides,
          target = (routeInfo.currentDepth - 1) * widthInPercent;

      app.filterModel.set({url: routeInfo.route});

      TweenMax.to(this.$contentWrapper,
        0.5,
        {
          x: '-' + target + '%',
          onComplete: function () {
            setTimeout(_.bind(function () {
              this.closeMenu();
              // app.filterModel.set({url: routeInfo.route});
              TweenMax.staggerFromTo($('.vigor-component'), 1, {autoAlpha: 0}, {autoAlpha: 1, position: 'relative'}, 0.1);
            }, this), 400);
          },
          onCompleteScope: this
        }
      );
    },

    onFilterChange: function () {
      console.log('onFilterChange: ', app.filterModel.toJSON());
      Vigor.componentManager.refresh(app.filterModel.toJSON());
    }

  });

})(jQuery);
