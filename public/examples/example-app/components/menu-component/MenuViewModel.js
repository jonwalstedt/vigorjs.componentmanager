var app = app || {};
app.components = app.components || {};

(function ($) {
  'use strict';
  var SubscriptionKeys = Vigor.SubscriptionKeys;
  app.components.MenuViewModel = Vigor.ComponentViewModel.extend({

    menuItems: undefined,

    constructor: function (options) {
      Vigor.ComponentViewModel.prototype.constructor.apply(this, arguments);
      this.menuItems = new Backbone.Collection([
        {
          label: 'Dashboard',
          href: '#'
        },
        {
          label: 'Projects',
          href: '#projects',
          submenu: [
            {
              label: 'List all',
              href: '#projects'
            },
            {
              label: 'Add new',
              href: '#projects/new'
            }
          ]
        },
        {
          label: 'Users',
          href: '#users',
          submenu: [
            {
              label: 'List all',
              href: '#users'
            },
            {
              label: 'Add new',
              href: '#users/new'
            }
          ]
        },
        {
          label: 'Reports',
          href: '#reports'
        },
        {
          label: 'Resources',
          href: '#resources'
        }
      ]);
    }

  });
})(jQuery);
