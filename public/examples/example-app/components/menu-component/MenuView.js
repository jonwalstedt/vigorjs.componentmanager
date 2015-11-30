define(function (require) {

  'use strict';

  var MenuView,
      $ = require('jquery'),
      _ = require('underscore'),
      ComponentViewBase = require('components/ComponentViewBase'),
      menuTemplate = require('hbars!./templates/menu-template'),
      linksTemplate = require('hbars!./templates/links-template');

  MenuView = ComponentViewBase.extend({

    className: 'menu-component',
    $personalMenu: undefined,
    $sectionsMenu: undefined,

    initialize: function () {
      ComponentViewBase.prototype.initialize.apply(this, arguments);
      this.listenTo(this.viewModel.availableSections, 'reset', this._onAvailableSectionsReset);
    },

    setActiveLink: function (url) {
      var $activeLink = this.$el.find('a[href="' + url + '"]');
      this.$el.find('.menu__link').removeClass('menu__link--active');
      $activeLink.addClass('menu__link--active');
    },

    renderStaticContent: function () {
      var templateData = {
        menuItems: this.viewModel.menuItems.toJSON()
      }
      this.$el.html(menuTemplate(templateData));
      this.$personalMenu = $('.personal-menu', this.$el);
      this.$sectionsMenu = $('.sections-menu', this.$el);
      this._renderDeferred.resolve();
      return this;
    },

    renderDynamicContent: function () {
      var sections = this.viewModel.availableSections.toJSON(),
          templateData = {links: sections},
          renderedSections = linksTemplate(templateData);

      this.$sectionsMenu.html(renderedSections);
    },

    addSubscriptions: function () {
      this.viewModel.addSubscriptions();
    },

    removeSubscriptions: function () {
      this.viewModel.removeSubscriptions();
    },

    dispose: function () {
      ComponentViewBase.prototype.dispose.call(this, arguments);
    },

    _onAvailableSectionsReset: function () {
      this.renderDynamicContent();
    }

  });

  return MenuView;

});
