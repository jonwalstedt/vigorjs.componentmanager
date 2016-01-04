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

      componentSettings = require('./componentSettings');

    ExampleProject = Backbone.View.extend({

      preloader: undefined,
      router: undefined,

      events: {
        'click .start-example-btn': 'startApplication',
        'click .example-app__menu-toggle': 'onMenuToggleClick'
      },

      $overlay: undefined,
      $contentWrapper: undefined,

      initialize: function () {
        this.router = new Router();
        this.preloader = new Preloader();
        this.pageView = new PageView({
          el: $('.content', this.$el).get(0)
        });

        componentManager.initialize({
          componentSettings: componentSettings,
          listenForMessages: true,
          context: this.$el
        });

        this.$overlay = $('.overlay', this.$el);
        this.$contentWrapper = $('.content-wrapper', this.$el);
        this.$menuToggle = $('.example-app__menu-toggle', this.$el);

        this.showOverlay();

        this.pageView.on('transition-complete', _.bind(this.onTransitionComplete, this));
        this.preloader.on('loading-complete', _.bind(this.onLoadingComplete, this));
        EventBus.subscribe(EventKeys.ROUTE_CHANGE, _.bind(this.onRouteChange, this));
        // EventBus.subscribe(EventKeys.COMPONENT_AREAS_ADDED, _.bind(this.onComponentAreasAdded, this));
      },

      startApplication: function () {
        this.$overlay.html(this.preloader.render().$el);
        Backbone.history.start({root: '/examples/example-app/'});
      },

      filterComponents: function (filter, preload) {
        if (typeof preload === 'undefined') {
          preload = false;
        }

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

      addMatchingComponents: function (route) {
        // Trigger filter change that will add components
        // whitout removing the old ones
        this.filterComponents({
          url: route,
          options: {
            remove: false
          }
        }, true);
      },

      removeNonMatchingComponents: function (route) {
        // This will only remove the components that no longer matches
        // the filter
        this.filterComponents({
          url: route,
          options: {
            add: false,
            remove: true
          }
        }, false);
      },

      // Callbacks
      // --------------------------------------------
      onRouteChange: function (routeInfo) {
        var index = routeInfo.index,
            route = routeInfo.route;

        // We need to wait to be sure that the class-names have been swapped
        // before adding new components
        _.defer(_.bind(function () {
          this.addMatchingComponents(route);
        }, this));

        this.pageView.transitionPages(index, route);
        this.closeMenu();
      },

      onTransitionComplete: function($el, route) {
        this.removeNonMatchingComponents(route);
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
        var $components = $('.main .vigor-component', this.$el);
        _.invoke(componentManager.getActiveInstances(), 'onPageReady');
        this.hideOverlay();
        TweenMax.staggerTo($components, 4, { autoAlpha: 1 }, 0.2 );
      },

      // new component-areas where added dynamically so we do another refresh to add
      // components that might go into those component-areas. We set remove to false to
      // not remove existing componetns in this case
      // onComponentAreasAdded: function () {

      //  this.filterComponents({
      //     route: this.router.getRoute(),
      //     options: {
      //       add: true,
      //       remove: false
      //     }
      //   },
      //   true);
      // }

    });

  return ExampleProject;
});
