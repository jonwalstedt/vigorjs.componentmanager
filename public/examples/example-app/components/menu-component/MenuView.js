define(function (require) {

  'use strict';

  var MenuView,
      $ = require('jquery'),
      _ = require('underscore'),
      ComponentViewBase = require('components/ComponentViewBase');

  MenuView = ComponentViewBase.extend({

    className: 'menu-component',
    componentName: 'menu',
    template: _.template($('script.menu-template').html()),

    setActiveLink: function (url) {
      var $activeLink = this.$el.find('a[href="' + url + '"]');
      this.$el.find('.menu__link').removeClass('menu__link--active');
      $activeLink.addClass('menu__link--active');
      console.log($activeLink);
    },

    renderStaticContent: function () {
      var templateData = {
        menuItems: this.viewModel.menuItems.toJSON()
      }
      this.$el.html(this.template(templateData));
      this._renderDeferred.resolve();
      return this;
    },

    renderDynamicContent: function () {},

    addSubscriptions: function () {},

    removeSubscriptions: function () {},

    dispose: function () {
      ComponentViewBase.prototype.dispose.apply(this, arguments);
    }

  });

  return MenuView;

});
