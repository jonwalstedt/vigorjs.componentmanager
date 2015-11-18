define(function (require) {

  'use strict';

  var ExampleProject,
      $ = require('jquery'),
      _ = require('underscore'),
      Backbone = require('backbone'),
      TweenMax = require('TweenMax'),
      Vigor = require('vigor'),
      componentManager = require('componentManager').componentManager,
      EventBus = Vigor.EventBus,
      EventKeys = require('EventKeys'),

      Router = require('./Router'),
      Preloader = require('./Preloader'),
      PageView = require('./PageView'),
      filterModel = require('./FilterModel'),

      componentSettings = require('./componentSettings');

    ExampleProject = Backbone.View.extend({

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
        this.$menuToggle = $('.menu-toggle', this.$el);

        componentManager.initialize({
          componentSettings: componentSettings,
          listenForMessages: true,
          context: this.$el
        });

        this.showOverlay();
        this.router = new Router();
        this.preloader = new Preloader();
        this.pageView = new PageView({
          el: $('.content', this.$el).get(0)
        });

        this.preloader.on('loading-complete', _.bind(this.onLoadingComplete, this));
        filterModel.on('change', _.bind(this.onFilterChange, this));
        this.router.on('route-change', _.bind(this.onRouteChange, this));
        EventBus.subscribe(EventKeys.COMPONENT_AREAS_ADDED, _.bind(this.onComponentAreasAdded, this));
      },

      startApplication: function () {
        this.$overlay.html(this.preloader.render().$el);
        Backbone.history.start({root: '/examples/example-app/'});
      },

      removePreloader: function () {
        this.preloader.off('loading-complete');
        this.preloader.remove();
        this.preloader = undefined;
        this.hideOverlay();
      },

      filterComponents: function () {
        var preload = filterModel.get('preload'),
            // we have to remove the preload property since its not to be used as
            // a part of the filter
            filter = _.omit(filterModel.toJSON(), 'preload');

        if (preload) {
          componentManager.refresh(filter).then(_.bind(function (activeInstancesObj) {
            var activeInstances = activeInstancesObj.activeInstances,
                promises = _.invoke(activeInstances, 'getRenderDonePromise');
            this.preloader.preload(promises);
          }, this));

        } else {
          componentManager.refresh(filter);
        }
      },

      openMenu: function () {
        this.$el.addClass('menu-visible');
        this.$menuToggle.addClass('close');
      },

      closeMenu: function () {
        this.$el.removeClass('menu-visible');
        this.$menuToggle.removeClass('close');
      },

      showOverlay: function () {
        this.$overlay.addClass('overlay--visible');
      },

      hideOverlay: function () {
        this.$overlay.removeClass('overlay--visible');
      },


      // Callbacks
      // --------------------------------------------
      onRouteChange: function (routeInfo) {
        var index = routeInfo.index,
            route = routeInfo.route;

        this.pageView.transitionPages(index, route);
        this.closeMenu();
      },

      onMenuToggleClick: function (event) {
        var $btn = $(event.currentTarget);

        if (this.$el.hasClass('menu-visible')) {
          this.closeMenu();
        } else {
          this.openMenu();
        }
      },

      onLoadingComplete: function () {
        var i, activeInstances = componentManager.getActiveInstances();
        this.hideOverlay();
        for (i = 0; i < activeInstances.length; i++) {
          activeInstances[i].onPageReady();
        }
        TweenMax.staggerTo($('.main .vigor-component', this.$el), 4,
          {
            autoAlpha: 1
          }, 0.2);
      },

      onFilterChange: function () {
        this.filterComponents();
      },

      // new component-areas where added dynamically so we do another refresh to add
      // components that might go into those component-areas. We set remove to false to
      // not remove existing componetns in this case
      onComponentAreasAdded: function () {
        console.log('onComponentAreasAdded');
        filterModel.resetAndSet({
          preload: true,
          options: {
            add: true,
            remove: false
          }
        });
      }

    });

  return ExampleProject;
});
