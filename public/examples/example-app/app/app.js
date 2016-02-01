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
        'click .start-example-btn': '_startApplication',
        'click .example-app__menu-toggle': '_onMenuToggleClick'
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

        this._showOverlay();

        this.pageView.on('transition-started', _.bind(this._onTransitionStarted, this));
        this.pageView.on('transition-complete', _.bind(this._onTransitionComplete, this));
        this.preloader.on('loading-complete', _.bind(this._onLoadingComplete, this));
        EventBus.subscribe(EventKeys.ROUTE_CHANGE, _.bind(this._onRouteChange, this));
        // EventBus.subscribe(EventKeys.COMPONENT_AREAS_ADDED, _.bind(this.onComponentAreasAdded, this));
      },

      _startApplication: function () {
        this.$overlay.html(this.preloader.render().$el);
        Backbone.history.start({root: '/examples/example-app/'});
      },

      _openMenu: function () {
        this.$el.addClass('menu-visible');
        this.$menuToggle.addClass('close');
      },

      _closeMenu: function () {
        this.$el.removeClass('menu-visible');
        this.$menuToggle.removeClass('close');
      },

      _showOverlay: function () {
        this.$overlay.addClass('overlay--visible');
      },

      _hideOverlay: function () {
        this.$overlay.removeClass('overlay--visible');
      },

      _addNewComponents: function (route) {
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

      _removeOldComponents: function (route) {
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
      _onRouteChange: function (routeInfo) {
        if (!routeInfo.isSubPage) {
          this.pageView.transitionPages(routeInfo.index, routeInfo.route);
        } else {
          this._removeOldComponents(routeInfo.route),
          this._addNewComponents(routeInfo.route);
          TweenMax.staggerTo($('.main .vigor-component', this.$el), 1, { autoAlpha: 1 }, 0.2 );
          _.invoke(componentManager.getActiveInstances(), 'onPageReady');
        }

        this._closeMenu();
      },

      _onTransitionStarted: function (route) {
        this._addNewComponents(route);
      },

      _onTransitionComplete: function($el, route) {
        $.when.apply($, [
          this._removeOldComponents(route),
          this.preloader.getLoadingPromise()
        ]).then(_.bind(function () {
          var $components = $('.main .vigor-component', this.$el);
          TweenMax.staggerTo($components, 4, { autoAlpha: 1 }, 0.2 );
          _.invoke(componentManager.getActiveInstances(), 'onPageReady');
        }, this));
      },

      _onMenuToggleClick: function (event) {
        if (this.$el.hasClass('menu-visible')) {
          this._closeMenu();
        } else {
          this._openMenu();
        }
      },

      _onLoadingComplete: function () {
        this._hideOverlay();
      }

    });

  return ExampleProject;
});
