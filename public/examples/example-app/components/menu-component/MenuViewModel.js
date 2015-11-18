define(function (require) {

  'use strict';

  var MenuViewModel,
      Backbone = require('backbone'),
      ComponentViewModel = require('vigor').ComponentViewModel;

  MenuViewModel = ComponentViewModel.extend({

    menuItems: undefined,

    constructor: function (options) {
      ComponentViewModel.prototype.constructor.apply(this, arguments);
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
              href: '#projects/all'
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
              href: '#users/all'
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

  return MenuViewModel;

});
