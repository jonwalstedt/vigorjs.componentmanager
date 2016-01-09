define(function (require) {

  'use strict';

  var FilterRepository,
      FilterModel = require('./FilterModel'),
      ServiceRepository = require('vigor').ServiceRepository,
      FilterService = require('services/FilterService');

  FilterRepository = ServiceRepository.extend({

    model: FilterModel,

    initialize: function () {
      FilterService.on(FilterService.FILTER_RECEIVED, _.bind(this._onFilterReceived, this));
      ServiceRepository.prototype.initialize.call(this, arguments);
    },

    getTimeFilter: function () {
      return this.where({type: 'time'});
    },

    getSectionFilters: function () {
      return this.where({type: 'section'});
    },

    getTimeFilterValue: function () {
      return _.map(this.getTimeFilter(), function (filter) {
        return filter.get('value');
      })[0];
    },

    getSectionsValueArray: function () {
      return _.map(this.getSectionFilters(), function (filter) {
        return filter.get('value');
      });
    },

    _onFilterReceived: function (models) {
      this.set(models);
    }
  });

  return new FilterRepository();

});
