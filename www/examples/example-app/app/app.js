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
        this.$menuToggle = $('.example-app__menu-toggle', this.$el);

        this.showOverlay();

        this.pageView.on('transition-started', _.bind(this.onTransitionStarted, this));
        this.pageView.on('transition-complete', _.bind(this.onTransitionComplete, this));
        this.preloader.on('loading-complete', _.bind(this.onLoadingComplete, this));
        EventBus.subscribe(EventKeys.ROUTE_CHANGE, _.bind(this.onRouteChange, this));
        // EventBus.subscribe(EventKeys.COMPONENT_AREAS_ADDED, _.bind(this.onComponentAreasAdded, this));
      },

      startApplication: function () {
        this.$overlay.html(this.preloader.render().$el);
        Backbone.history.start({root: '/examples/example-app/'});
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

      addNewComponents: function (route) {
        // Trigger filter change that will add new (matching) components
        // whitout removing the old ones
        var promise = componentManager.refresh({
          url: route,
          options: {
            remove: false
          }
        });

        promise.then(_.bind(function (activeInstancesObj) {
          var activeInstances = activeInstancesObj.activeInstances,
              promises = _.invoke(activeInstances, 'getRenderDonePromise');
          this.preloader.preload(promises);
        }, this));

        return promise;
      },

      removeOldComponents: function (route) {
        // This will only remove the components that no longer matches (returns a promise)
        return componentManager.refresh({
          url: route,
          options: {
            add: false,
            remove: true
          }
        });
      },

      // Callbacks
      // --------------------------------------------
      onRouteChange: function (routeInfo) {
        this.pageView.transitionPages(routeInfo.index, routeInfo.route);
        this.closeMenu();
      },

      onTransitionStarted: function (route) {
        this.addNewComponents(route);
      },

      onTransitionComplete: function($el, route) {
        $.when.apply($, [
          this.removeOldComponents(route),
          this.preloader.getLoadingCompletePromise()
        ]).then(_.bind(function () {
          var $components = $('.main .vigor-component', this.$el);
          TweenMax.staggerTo($components, 4, { autoAlpha: 1 }, 0.2 );
          _.invoke(componentManager.getActiveInstances(), 'onPageReady');
        }, this));
      },

      onMenuToggleClick: function (event) {
        if (this.$el.hasClass('menu-visible')) {
          this.closeMenu();
        } else {
          this.openMenu();
        }
      },

      onLoadingComplete: function () {
        this.hideOverlay();
      }

    });

  return ExampleProject;
});
