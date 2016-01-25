define(function (require) {

  'use strict';

  var MenuView,
      $ = require('jquery'),
      ComponentViewBase = require('components/ComponentViewBase'),
      Backbone = require('backbone'),
      menuTemplate = require('hbars!./templates/menu-template');

  MenuView = Backbone.View.extend({

    className: 'menu-component',
    _renderDeferred: undefined,
    $mainMenu: undefined,

    initialize: function () {
      this._renderDeferred = $.Deferred();
    },

    getRenderDonePromise: function () {
      return this._renderDeferred.promise();
    },

    setActiveLink: function (url) {
      var $activeLink = this.$el.find('a[href="' + url + '"]');
      this.$el.find('.menu__link').removeClass('menu__link--active');
      $activeLink.addClass('menu__link--active');
    },

    render: function () {
      this.$el.html(menuTemplate());
      this.$mainMenu = $('.main-menu', this.$el);
      this._renderDeferred.resolve();
      return this;
    },

    dispose: function () {
      this.remove();
    }

  });

  return MenuView;

});
