define(function (require) {

  'use strict';

  var MenuViewModel,
      Backbone = require('backbone'),
      ComponentViewModel = require('vigor').ComponentViewModel,
      subscriptionKey = require('SubscriptionKeys');

  MenuViewModel = ComponentViewModel.extend({

    menuItems: undefined,
    availableSections: undefined,

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
      this.availableSections = new Backbone.Collection();
    },

    addSubscriptions: function () {
      // this.subscribe(subscriptionKey.AVAILABLE_SECTIONS, _.bind(this._availableSectionsChange, this), {});
    },

    removeSubscriptions: function () {
      // this.unsubscribe(this.subscriptionKey);
    },

    _availableSectionsChange: function (availableSections) {
      // console.log('_availableSectionsChange: ', availableSections);
      if (this.availableSections.length === 0 && availableSections.length > 0) {
        this.availableSections.reset(availableSections);
      } else {
        this.availableSections.set(availableSections);
      }
    }

  });

  return MenuViewModel;

});
