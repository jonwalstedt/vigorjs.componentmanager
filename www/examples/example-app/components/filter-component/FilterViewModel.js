define(function (require) {

  'use strict';

  var FilterViewModel,
      SectionCollection = require('./sections-filter/SectionsCollection'),
      TimeModel = require('./time-filter/TimeModel'),
      ComponentViewModel = require('vigor').ComponentViewModel,
      subscriptionKeys = require('SubscriptionKeys');

  FilterViewModel = ComponentViewModel.extend({

    sectionsCollection: undefined,
    timeModel: undefined,

    constructor: function (options) {
      ComponentViewModel.prototype.constructor.apply(this, arguments);
      this.sectionsCollection = new SectionCollection();
      this.timeModel = new TimeModel();
    },

    addSubscriptions: function () {
      this.subscribe(subscriptionKeys.FILTER, _.bind(this._onFilterChange, this), {});
    },

    removeSubscriptions: function () {
      this.unsubscribe(this.subscriptionKey);
    },

    getSelectedSections: function () {
      return this.sectionsCollection.where({selected: true});
    },

    getSelectedTime: function () {
      return this.timeModel.get('selectedTime');
    },

    _onFilterChange: function (filter) {
      this.timeModel.set({'selectedTime': filter.time}, {silent: true});
      this.sectionsCollection.set(filter.sections);
    }

  });

  return FilterViewModel;

});
